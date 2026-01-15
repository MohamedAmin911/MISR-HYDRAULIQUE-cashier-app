using System;
using System.Drawing;
using System.IO;
using System.Windows.Forms;
using Microsoft.Web.WebView2.Core;
using Microsoft.Web.WebView2.WinForms;

namespace MisrHydraulique
{
public class MainForm : Form
{
private readonly WebView2 webView = new WebView2();


    public MainForm()
    {
        Text = "MisrHydraulique";
        WindowState = FormWindowState.Maximized;

        // Optional: app icon
        var icoPath = Path.Combine(AppContext.BaseDirectory, "Assets", "app.ico");
        if (File.Exists(icoPath)) this.Icon = new Icon(icoPath);

        Controls.Add(webView);
        webView.Dock = DockStyle.Fill;

        Load += MainForm_LoadAsync;
    }

    private async void MainForm_LoadAsync(object? sender, EventArgs e)
    {
        var exeDir  = AppContext.BaseDirectory;
        var webDir  = Path.Combine(exeDir, "web");        // Flutter build
        var runtime = Path.Combine(exeDir, "WebView2");    // Fixed version runtime (portable)
        var userData = Path.Combine(exeDir, "Data");       // PORTABLE DATA HERE
        Directory.CreateDirectory(userData);

        try
        {
            CoreWebView2Environment env;
            if (Directory.Exists(runtime) &&
                File.Exists(Path.Combine(runtime, "msedgewebview2.exe")))
            {
                env = await CoreWebView2Environment.CreateAsync(
                    browserExecutableFolder: runtime,
                    userDataFolder: userData);
            }
            else
            {
                // Fallback to system Evergreen runtime if available
                env = await CoreWebView2Environment.CreateAsync(userDataFolder: userData);
            }

            await webView.EnsureCoreWebView2Async(env);

            if (!Directory.Exists(webDir) || !File.Exists(Path.Combine(webDir, "index.html")))
            {
                MessageBox.Show(
                    "web/index.html غير موجود.\nانسخ مجلد Flutter build/web إلى مجلد 'web' بجانب الملف التنفيذي.",
                    "ملفات مفقودة",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
                return;
            }

            webView.CoreWebView2.Settings.AreDefaultContextMenusEnabled = false;
            webView.CoreWebView2.Settings.AreDevToolsEnabled = false;

            // Map a secure virtual host to local folder (service worker works)
            webView.CoreWebView2.SetVirtualHostNameToFolderMapping(
                "app.local",
                webDir,
                CoreWebView2HostResourceAccessKind.Allow);

            webView.Source = new Uri("https://app.local/index.html");
        }
        catch (Exception ex)
        {
            MessageBox.Show(
                "فشل تهيئة WebView2.\n\n" +
                "1) ضمّن WebView2 (Fixed Version) تحت مجلد 'WebView2'\n" +
                "2) أو ثبّت WebView2 Evergreen: https://aka.ms/msedgewebview2setup\n\n" +
                $"التفاصيل:\n{ex.Message}",
                "WebView2",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error);
        }
    }
}
}