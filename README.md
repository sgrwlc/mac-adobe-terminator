# Mac Adobe Process Terminator

A robust bash script to safely terminate all Adobe and Creative Cloud processes on macOS.

## Why This Script?

Adobe's Creative Cloud applications are known for running numerous background processes that can consume system resources even when you're not actively using Adobe products. These processes can be difficult to completely terminate through normal means. This script provides a comprehensive solution to kill all Adobe-related processes in one go.

## Features

- Terminates all Adobe and Creative Cloud applications and background processes
- Color-coded output for better readability
- Detailed reporting of terminated processes
- Verification to ensure all processes are stopped
- Checks for and recommends sudo privileges when needed
- Handles various edge cases and provides helpful error messages

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/mac-adobe-terminator.git
cd mac-adobe-terminator

# Make the script executable
chmod +x kill-adobe.sh
```

## Usage

For best results, run with sudo privileges:

```bash
sudo ./kill-adobe.sh
```

Or without sudo (some processes might not terminate):

```bash
./kill-adobe.sh
```

## How It Works

The script uses a multi-layered approach to ensure all Adobe processes are terminated:

1. Terminates processes with "Adobe" in the name
2. Terminates processes with "Creative Cloud" in the name
3. Specifically targets known Adobe background services by name
4. Searches for any remaining Adobe-related processes
5. Verifies all processes have been terminated

## Compatibility

- macOS 10.13 (High Sierra) and later
- Bash 3.2+

## License

MIT License - See LICENSE file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Disclaimer

This script is provided as-is with no warranties. Always save your work before terminating processes.