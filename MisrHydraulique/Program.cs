using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace MisrHydraulique
{
internal static class Program
{
[DllImport("shell32.dll")]
static extern int SetCurrentProcessExplicitAppUserModelID(
[MarshalAs(UnmanagedType.LPWStr)] string appID);



    [STAThread]
    static void Main()
    {
        ApplicationConfiguration.Initialize();
        SetCurrentProcessExplicitAppUserModelID("MisrHydraulique.OfflinePOS");
        Application.Run(new MainForm());
    }
}
}