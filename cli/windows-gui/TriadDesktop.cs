using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

internal static class Program
{
    [STAThread]
    private static void Main()
    {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);
        Application.Run(new TriadDesktopForm());
    }
}

internal sealed class TriadDesktopForm : Form
{
    private readonly TextBox projectPathBox;
    private readonly RichTextBox outputConsole;
    private readonly Label statusLabel;
    private readonly Button browseButton;
    private readonly Button[] commandButtons;
    private string projectRoot;
    private string cliPath;
    private bool isRunning;

    internal TriadDesktopForm()
    {
        Text = "Triad 2.0 \u2014 CLI";
        Width = 920;
        Height = 620;
        MinimumSize = new Size(700, 450);
        StartPosition = FormStartPosition.CenterScreen;

        Icon applicationIcon = Icon.ExtractAssociatedIcon(Application.ExecutablePath);
        if (applicationIcon != null)
        {
            Icon = applicationIcon;
        }

        var projectLabel = new Label
        {
            AutoSize = true,
            Left = 12,
            Top = 12,
            Text = "Cartella progetto"
        };
        projectPathBox = new TextBox
        {
            AccessibleName = "projectPath",
            Anchor = AnchorStyles.Left | AnchorStyles.Top | AnchorStyles.Right,
            Left = 12,
            Top = 34,
            Width = 730,
            ReadOnly = true
        };
        browseButton = new Button
        {
            AccessibleName = "browseProject",
            Anchor = AnchorStyles.Top | AnchorStyles.Right,
            Left = 752,
            Top = 32,
            Width = 140,
            Height = 26,
            Text = "Scegli cartella"
        };
        browseButton.Click += BrowseButtonClick;

        var header = new Panel
        {
            Dock = DockStyle.Top,
            Height = 70
        };
        header.Controls.Add(projectLabel);
        header.Controls.Add(projectPathBox);
        header.Controls.Add(browseButton);
        header.Resize += delegate
        {
            projectPathBox.Width = header.ClientSize.Width - browseButton.Width - 36;
            browseButton.Left = header.ClientSize.Width - browseButton.Width - 12;
        };

        var commandPanel = new FlowLayoutPanel
        {
            AutoSize = false,
            Dock = DockStyle.Top,
            Height = 44,
            Padding = new Padding(8, 6, 8, 4),
            WrapContents = false
        };

        commandButtons = new[]
        {
            CreateCommandButton("Stato", new[] { "status" }),
            CreateCommandButton("Test unitari", new[] { "test", "run" }),
            CreateCommandButton("Conformance", new[] { "test", "conformance" }),
            CreateCommandButton("AI verify", new[] { "ai", "verify" })
        };
        foreach (Button button in commandButtons)
        {
            commandPanel.Controls.Add(button);
        }

        outputConsole = new RichTextBox
        {
            AccessibleName = "outputConsole",
            Dock = DockStyle.Fill,
            Font = new Font("Consolas", 10F),
            Name = "outputConsole",
            ReadOnly = true,
            WordWrap = false
        };
        statusLabel = new Label
        {
            AccessibleName = "statusLabel",
            AutoEllipsis = true,
            Dock = DockStyle.Bottom,
            Height = 24,
            Padding = new Padding(8, 4, 8, 2),
            Text = "Seleziona un'azione."
        };

        Controls.Add(outputConsole);
        Controls.Add(statusLabel);
        Controls.Add(commandPanel);
        Controls.Add(header);

        SetProjectRoot(FindProjectRoot());
    }

    private Button CreateCommandButton(string label, string[] arguments)
    {
        var button = new Button
        {
            AccessibleName = label,
            AutoSize = true,
            Height = 28,
            Name = label,
            Text = label,
            Tag = arguments
        };
        button.Click += async delegate
        {
            await RunCommandAsync((string[])button.Tag);
        };
        return button;
    }

    private void BrowseButtonClick(object sender, EventArgs eventArgs)
    {
        using (var dialog = new FolderBrowserDialog())
        {
            dialog.Description = "Scegli la cartella del repository Triad 2.0.";
            if (Directory.Exists(projectRoot))
            {
                dialog.SelectedPath = projectRoot;
            }

            if (dialog.ShowDialog(this) != DialogResult.OK)
            {
                return;
            }

            if (!IsProjectRoot(dialog.SelectedPath))
            {
                MessageBox.Show(
                    this,
                    "La cartella scelta non contiene conformance\\run.mjs e seed.",
                    "Cartella progetto non valida",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning);
                return;
            }

            SetProjectRoot(Path.GetFullPath(dialog.SelectedPath));
        }
    }

    private void SetProjectRoot(string root)
    {
        projectRoot = root;
        projectPathBox.Text = root ?? "Nessun progetto selezionato";
        cliPath = FindCliPath(root);

        foreach (Button button in commandButtons)
        {
            button.Enabled = IsCommandAvailable(button);
        }

        statusLabel.Text = root != null && cliPath != null
            ? "Pronto"
            : root == null && cliPath != null
                ? "CLI pronto. Scegli la cartella progetto per gli altri comandi."
                : root == null
                    ? "Seleziona la cartella del repository Triad 2.0."
                    : "triad-cli.exe non trovato nella cartella del progetto.";

        if (root != null && cliPath == null)
        {
            AppendOutput("CLI non trovato. Atteso in cli\\dist, bin oppure nella root del repository.");
        }
    }

    private async Task RunCommandAsync(string[] arguments)
    {
        if (isRunning || cliPath == null || (projectRoot == null && arguments[0] != "status"))
        {
            return;
        }

        isRunning = true;
        foreach (Button button in commandButtons)
        {
            button.Enabled = false;
        }

        outputConsole.Clear();
        statusLabel.Text = "In esecuzione...";
        AppendOutput("> triad-cli " + string.Join(" ", arguments));

        try
        {
            var startInfo = new ProcessStartInfo
            {
                Arguments = string.Join(" ", arguments),
                CreateNoWindow = true,
                FileName = cliPath,
                RedirectStandardError = true,
                RedirectStandardOutput = true,
                StandardErrorEncoding = Encoding.UTF8,
                StandardOutputEncoding = Encoding.UTF8,
                UseShellExecute = false,
                WorkingDirectory = projectRoot ?? GetApplicationDirectory()
            };
            if (projectRoot != null)
            {
                startInfo.EnvironmentVariables["TRIAD_HOME"] = projectRoot;
            }

            using (var process = new Process { StartInfo = startInfo })
            {
                process.OutputDataReceived += ProcessOutputReceived;
                process.ErrorDataReceived += ProcessOutputReceived;

                if (!process.Start())
                {
                    throw new InvalidOperationException("Impossibile avviare triad-cli.exe.");
                }

                process.BeginOutputReadLine();
                process.BeginErrorReadLine();
                await Task.Run(delegate { process.WaitForExit(); });
                process.WaitForExit();

                AppendOutput("Processo terminato con codice " + process.ExitCode + ".");
                statusLabel.Text = process.ExitCode == 0
                    ? "Operazione completata."
                    : "Operazione terminata con errori (codice " + process.ExitCode + ").";
            }
        }
        catch (System.ComponentModel.Win32Exception error)
        {
            AppendOutput("Errore di avvio: " + error.Message);
            statusLabel.Text = "Impossibile avviare triad-cli.exe.";
        }
        catch (InvalidOperationException error)
        {
            AppendOutput("Errore: " + error.Message);
            statusLabel.Text = "Impossibile eseguire il comando.";
        }
        finally
        {
            isRunning = false;
            foreach (Button button in commandButtons)
            {
                button.Enabled = IsCommandAvailable(button);
            }
        }
    }

    private void ProcessOutputReceived(object sender, DataReceivedEventArgs eventArgs)
    {
        if (eventArgs.Data != null)
        {
            AppendOutput(eventArgs.Data);
        }
    }

    private void AppendOutput(string text)
    {
        if (IsDisposed || !IsHandleCreated)
        {
            return;
        }

        if (InvokeRequired)
        {
            BeginInvoke(new Action<string>(AppendOutput), text);
            return;
        }

        outputConsole.AppendText(text + Environment.NewLine);
        outputConsole.SelectionStart = outputConsole.TextLength;
        outputConsole.ScrollToCaret();
    }

    private static string FindProjectRoot()
    {
        string applicationDirectory = GetApplicationDirectory();
        string[] starts =
        {
            Environment.GetEnvironmentVariable("TRIAD_HOME"),
            applicationDirectory,
            Path.GetFullPath(Path.Combine(applicationDirectory, "..", "..")),
            Environment.CurrentDirectory
        };

        foreach (string start in starts)
        {
            if (string.IsNullOrWhiteSpace(start))
            {
                continue;
            }

            DirectoryInfo directory;
            try
            {
                directory = new DirectoryInfo(Path.GetFullPath(start));
            }
            catch (ArgumentException)
            {
                continue;
            }
            catch (PathTooLongException)
            {
                continue;
            }

            while (directory != null)
            {
                if (IsProjectRoot(directory.FullName))
                {
                    return directory.FullName;
                }

                directory = directory.Parent;
            }
        }

        return null;
    }

    private static bool IsProjectRoot(string path)
    {
        return Directory.Exists(path)
            && File.Exists(SafeCombine(path, "conformance", "run.mjs"))
            && Directory.Exists(SafeCombine(path, "seed"));
    }

    // Path.Combine silently drops earlier segments if a later one is rooted
    // (e.g. an absolute or drive-relative path). SafeCombine rejects that by
    // requiring every segment to be a plain relative name without a root.
    private static string SafeCombine(params string[] parts)
    {
        foreach (string part in parts.Skip(1))
        {
            if (Path.IsPathRooted(part))
            {
                throw new ArgumentException(
                    "Path segment must not be rooted: " + part, nameof(parts));
            }
        }
        return Path.Combine(parts);
    }

    private static string FindCliPath(string root)
    {
        if (root == null)
        {
            string[] standaloneCandidates =
            {
                Path.Combine(GetApplicationDirectory(), "triad-cli.exe"),
                Path.Combine(Environment.CurrentDirectory, "cli", "dist", "triad-cli.exe"),
                Path.Combine(Environment.CurrentDirectory, "bin", "triad-cli.exe"),
                Path.Combine(Environment.CurrentDirectory, "triad-cli.exe")
            };
            foreach (string candidate in standaloneCandidates)
            {
                if (File.Exists(candidate))
                {
                    return Path.GetFullPath(candidate);
                }
            }

            return null;
        }

        string[] candidates =
        {
            Path.Combine(root, "cli", "dist", "triad-cli.exe"),
            Path.Combine(root, "bin", "triad-cli.exe"),
            Path.Combine(root, "triad-cli.exe")
        };

        foreach (string candidate in candidates)
        {
            if (File.Exists(candidate))
            {
                return Path.GetFullPath(candidate);
            }
        }

        return null;
    }

    private static string GetApplicationDirectory()
    {
        return Path.GetDirectoryName(Application.ExecutablePath);
    }

    private bool IsCommandAvailable(Button button)
    {
        if (isRunning || cliPath == null)
        {
            return false;
        }

        string[] arguments = (string[])button.Tag;
        return projectRoot != null || arguments[0] == "status";
    }
}
