// Ghidra headless script -- Stuxnet s7otbxdx.dll export-forwarding analysis.
//
// For each export in the loaded program, decide whether it is a "forwarder"
// (re-exports a function from another DLL via the export name string) or a
// real local implementation. In Stuxnet's s7otbxdx.dll hijacker, ~90% of
// exports forward to s7otbxsx.<name>; the small set that does NOT forward
// is the hooked subset that intercepts PLC block read/write -- that's what
// you reverse for section 5.1 of the report.
//
// Output:
//   <repo>/analysis/<binary>/exports.csv
//   <repo>/analysis/<binary>/hooked-exports.txt   (the non-forwarders)
//
// Run inside the static-lab container:
//   make shell
//   ghidra-headless /tmp/gp s7analysis \
//       -import samples/s7otbxdx.dll \
//       -postScript scripts/ghidra/StuxnetExportAnalysis.java \
//       -deleteProject
//
// @category Stuxnet
// @author school project

import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.Address;
import ghidra.program.model.symbol.Symbol;
import ghidra.program.model.symbol.SymbolIterator;
import ghidra.program.model.symbol.SymbolTable;
import ghidra.program.model.symbol.SymbolType;
import ghidra.program.model.data.Pointer;
import ghidra.program.model.data.PointerDataType;
import ghidra.program.model.listing.Data;
import ghidra.program.model.listing.Function;

import java.io.File;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

public class StuxnetExportAnalysis extends GhidraScript {

    @Override
    protected void run() throws Exception {
        SymbolTable st = currentProgram.getSymbolTable();
        SymbolIterator it = st.getAllSymbols(true);

        List<String[]> rows = new ArrayList<>();
        List<String> hooked = new ArrayList<>();

        int total = 0, forwarders = 0, locals = 0;

        while (it.hasNext() && !monitor.isCancelled()) {
            Symbol s = it.next();
            if (!s.isExternalEntryPoint()) continue;
            if (s.getSymbolType() != SymbolType.FUNCTION
                && s.getSymbolType() != SymbolType.LABEL) continue;

            total++;
            String name = s.getName();
            Address addr = s.getAddress();

            String forwardTarget = detectForwarder(addr);
            String type;
            if (forwardTarget != null) {
                forwarders++;
                type = "forwarder";
            } else {
                locals++;
                type = "local";
                hooked.add(String.format("%s @ %s", name, addr));
            }
            rows.add(new String[]{ name, addr.toString(), type,
                                   forwardTarget == null ? "" : forwardTarget });
        }

        // Write outputs into a path that lines up with the lab's analysis/ tree.
        String binName = currentProgram.getName();
        File outDir = new File("analysis/" + binName);
        outDir.mkdirs();

        File csv = new File(outDir, "exports.csv");
        try (PrintWriter pw = new PrintWriter(new FileWriter(csv))) {
            pw.println("name,address,type,forwarder_target");
            for (String[] r : rows) {
                pw.printf("%s,%s,%s,%s%n", r[0], r[1], r[2], r[3]);
            }
        }

        File hookedFile = new File(outDir, "hooked-exports.txt");
        try (PrintWriter pw = new PrintWriter(new FileWriter(hookedFile))) {
            pw.println("# Exports that are NOT export-forwarders.");
            pw.println("# In Stuxnet's s7otbxdx.dll, this is the hooked subset");
            pw.println("# that intercepts PLC block read/write. Reverse each.");
            pw.println();
            for (String h : hooked) pw.println(h);
        }

        println("[+] " + total + " exports total");
        println("    forwarders: " + forwarders);
        println("    local:      " + locals);
        println("[+] wrote " + csv.getAbsolutePath());
        println("[+] wrote " + hookedFile.getAbsolutePath());
    }

    /**
     * Detect whether the export at {@code addr} is an export forwarder.
     *
     * In a PE export directory, a forwarder's RVA points to an ASCII string
     * inside the .rdata / export section of the form "OtherDll.FunctionName"
     * rather than to executable code. Ghidra represents the export entry
     * itself as a label at the forwarder string; the data at that address
     * is a string, not a function.
     */
    private String detectForwarder(Address addr) throws Exception {
        Function fn = getFunctionAt(addr);
        if (fn != null) {
            return null; // It's a real function body -- not a forwarder.
        }

        Data data = getDataAt(addr);
        if (data == null) return null;

        Object value = data.getValue();
        if (value instanceof String) {
            String s = (String) value;
            if (s.contains(".") && s.length() < 256) {
                return s;
            }
        }
        // Fall back: read raw bytes and look for an ASCII forwarder pattern.
        try {
            byte[] bytes = new byte[128];
            int n = currentProgram.getMemory().getBytes(addr, bytes);
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < n; i++) {
                byte b = bytes[i];
                if (b == 0) break;
                if (b < 0x20 || b > 0x7e) return null;
                sb.append((char) b);
            }
            String candidate = sb.toString();
            if (candidate.contains(".") && candidate.length() >= 5) {
                return candidate;
            }
        } catch (Exception e) {
            // Memory read failed -- treat as not-a-forwarder.
        }
        return null;
    }
}
