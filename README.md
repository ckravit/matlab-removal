# MATLAB Removal Script for Ubuntu

A small cleanup script for removing MATLAB, MathWorks Service Host, MATLAB Proxy, desktop launchers, profile hooks, and related user-level remnants from an Ubuntu system.

This was created for clean/test Ubuntu systems where MATLAB was installed but should not remain on the machine.

## Script

Expected script name:

```bash
matlab-removal.sh
```

## What it removes

The script targets common MATLAB and MathWorks remnants, including:

* System MATLAB paths under `/usr/local`, `/usr/share`, `/opt/MathWorks`, and `/opt/mathworks`
* MATLAB command-line launchers such as `/usr/local/bin/matlab`
* MATLAB Connector remnants
* MATLAB Proxy service files
* MATLAB-related desktop launchers and icons
* MathWorks profile scripts under `/etc/profile.d`
* User-level MATLAB folders under `/home/*` and `/home/AD/*`
* Root user MATLAB remnants
* Default skeleton user files under `/etc/skel`

It also reloads systemd after removing service files.

## Safety behavior

The script runs in **dry-run mode by default**.

Running the script without arguments prints what would be removed, but does not delete anything:

```bash
sudo ./matlab-removal.sh
```

To actually remove files, run:

```bash
sudo ./matlab-removal.sh --execute
```

The script must be run with `sudo` or as root.

## Usage

Make the script executable:

```bash
chmod +x matlab-removal.sh
```

Run a dry run first:

```bash
sudo ./matlab-removal.sh
```

Review the output carefully.

Then run the actual removal:

```bash
sudo ./matlab-removal.sh --execute
```

## Follow-up checks

After running the script, you can check for remaining MATLAB or MathWorks package entries:

```bash
dpkg -l | grep -Ei 'matlab|mathworks'
```

You can also search common system locations for leftover files:

```bash
sudo find /etc /opt /usr/local /usr/share \( -iname '*matlab*' -o -iname '*mathworks*' \)
```

Some remaining results may be normal and should not necessarily be removed. For example, syntax-highlighting or MIME support files from Vim, GTK, CUDA documentation, or source-highlight are not MATLAB installations.

Examples of harmless leftovers may include files like:

```text
/usr/share/vim/.../syntax/matlab.vim
/usr/share/mime/text/x-matlab.xml
/usr/share/gtksourceview-*/language-specs/matlab.lang
/usr/local/cuda-toolkit/.../lang-matlab.js
```

## Notes

This script is intentionally broad in some places because it is intended for clean systems where MATLAB was installed accidentally or temporarily.

Be cautious using it on shared systems or systems where users may have legitimate MATLAB files under their home directories. The script removes folders such as:

```text
/home/*/Documents/MATLAB
/home/*/.matlab
/home/AD/*/Documents/MATLAB
/home/AD/*/.matlab
```

Only run the execute mode after reviewing the dry-run output.

## Disclaimer

This script is provided as-is. Review the dry-run output before using execute mode, especially on production or shared systems.
