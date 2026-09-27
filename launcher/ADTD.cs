// ADTD Modern launcher (ADTD.exe).
// Opens the ADTD Modern window inside this process, so Windows shows the ADTD Modern
// icon on the taskbar (not the PowerShell one) and the app can be pinned.
// It hosts Windows PowerShell 5.1 (System.Management.Automation from the GAC), loads
// ADTD.psd1 from the same folder and calls Show-ADTD. No console window is shown.
//
// Build (Windows):  C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe /target:winexe /win32icon:..\src\ADTD.ico /out:..\src\ADTD.exe ADTD.cs
// Build (Linux):    mcs -sdk:4.5 -target:winexe -win32icon:../src/ADTD.ico -r:System.Windows.Forms.dll -out:../src/ADTD.exe ADTD.cs

using System;
using System.Collections;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Forms;

[assembly: AssemblyTitle("ADTD Modern")]
[assembly: AssemblyDescription("Active Directory topology, security and hybrid Entra ID assessment")]
[assembly: AssemblyCompany("Shenuka Fernando")]
[assembly: AssemblyProduct("ADTD Modern")]
[assembly: AssemblyCopyright("Copyright (c) 2026 Shenuka Fernando")]
[assembly: AssemblyVersion("3.0.3.0")]
[assembly: AssemblyFileVersion("3.0.3.0")]
[assembly: AssemblyInformationalVersion("3.0.3")]

static class Program
{
    [DllImport("user32.dll")]
    static extern bool SetProcessDPIAware();

    const string Sma = "System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35";

    [STAThread]
    static int Main(string[] args)
    {
        try { SetProcessDPIAware(); } catch { }
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);

        bool welcome = false;
        foreach (string a in args)
        {
            string s = a.TrimStart('-', '/').ToLowerInvariant();
            if (s == "welcome") welcome = true;
        }

        string dir = AppDomain.CurrentDomain.BaseDirectory;
        string psd1 = Path.Combine(dir, "ADTD.psd1");
        if (!File.Exists(psd1))
        {
            Fail("ADTD.psd1 was not found in " + dir + ".\n\nKeep ADTD.exe in the same folder as the ADTD module files.");
            return 1;
        }

        try
        {
            Assembly sma = Assembly.Load(Sma);
            Type rfType = sma.GetType("System.Management.Automation.Runspaces.RunspaceFactory", true);
            object rs = rfType.GetMethod("CreateRunspace", Type.EmptyTypes).Invoke(null, null);
            Type rsType = sma.GetType("System.Management.Automation.Runspaces.Runspace", true);
            // Run on this (STA) thread: Windows Forms needs STA, and the window then belongs to ADTD.exe.
            rsType.GetProperty("ApartmentState").SetValue(rs, System.Threading.ApartmentState.STA, null);
            Type thr = sma.GetType("System.Management.Automation.Runspaces.PSThreadOptions", true);
            rsType.GetProperty("ThreadOptions").SetValue(rs, Enum.Parse(thr, "UseCurrentThread"), null);
            Method(rsType, "Open", 0).Invoke(rs, null);

            Type psType = sma.GetType("System.Management.Automation.PowerShell", true);
            object ps = Method(psType, "Create", 0).Invoke(null, null);
            psType.GetProperty("Runspace").SetValue(ps, rs, null);
            string script =
                "try { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force -ErrorAction Stop } catch { }\n" +
                "Import-Module $args[0] -Force -ErrorAction Stop\n" +
                "if ($args[1]) { Show-ADTD -Welcome -HostPath $args[2] } else { Show-ADTD -HostPath $args[2] }";
            Method(psType, "AddScript", 1).Invoke(ps, new object[] { script });
            MethodInfo addArg = Method(psType, "AddArgument", 1);
            addArg.Invoke(ps, new object[] { psd1 });
            addArg.Invoke(ps, new object[] { welcome });
            addArg.Invoke(ps, new object[] { Application.ExecutablePath });
            Method(psType, "Invoke", 0).Invoke(ps, null);

            object streams = psType.GetProperty("Streams").GetValue(ps, null);
            IEnumerable errors = (IEnumerable)streams.GetType().GetProperty("Error").GetValue(streams, null);
            StringBuilder sb = new StringBuilder();
            foreach (object e in errors) { sb.AppendLine(e.ToString()); }
            if (sb.Length > 0) { Fail(sb.ToString()); return 2; }
            return 0;
        }
        catch (Exception ex)
        {
            while (ex is TargetInvocationException && ex.InnerException != null) ex = ex.InnerException;
            Fail(ex.Message + "\n\nADTD Modern needs Windows PowerShell 5.1, which is part of Windows 10/11 and Windows Server 2016 or later.");
            return 3;
        }
    }

    // The non-generic public overload with this many parameters (the first parameter a string when there is one).
    static MethodInfo Method(Type t, string name, int parameters)
    {
        foreach (MethodInfo m in t.GetMethods(BindingFlags.Public | BindingFlags.Instance | BindingFlags.Static))
        {
            if (m.Name != name || m.IsGenericMethodDefinition) continue;
            ParameterInfo[] p = m.GetParameters();
            if (p.Length != parameters) continue;
            if (parameters == 1 && name == "AddScript" && p[0].ParameterType != typeof(string)) continue;
            if (parameters == 1 && name == "AddArgument" && p[0].ParameterType != typeof(object)) continue;
            return m;
        }
        throw new MissingMethodException(t.FullName, name);
    }

    static void Fail(string message)
    {
        MessageBox.Show(message, "ADTD Modern", MessageBoxButtons.OK, MessageBoxIcon.Error);
    }
}
