# Burp Suite Professional

**Enhance Your Testing Skills with Burp Suite Professional**
_~Test like a Pro, with Ignorance is a Bliss as a Motto_

![BurpSuite-Banner](https://raw.githubusercontent.com/crisa97/BurpSuiteLoaderGen/main/Media/BurpSuitePro_2.png)

## Disclaimer

This repository is intended solely for educational purposes, or maybe not who knows?

## Overview

This repository provides a streamlined method for installing Burp Suite Professional with a single command. While a manual installation guide is also available, we recommend the automated process for convenience.

![BurpSuiteProfessional](https://raw.githubusercontent.com/crisa97/BurpSuiteLoaderGen/main/Media/BurpSuitePro_3.png)

# Linux Installation

## Prerequisites

Before proceeding with the installation, ensure that the following dependencies are installed on your system:

### General Dependencies

- `git` - for version control
- `curl` or `wget` - for downloading files

### Ubuntu/Debian-based Systems

```bash
sudo apt-get install -y openjdk-22-jre openjdk-22-jdk git curl wget
```

### Fedora-based Systems

```bash
sudo dnf install -y java-22-openjdk java-22-openjdk-devel git curl wget
```

### CentOS/RHEL-based Systems

```bash
sudo yum install -y java-22-openjdk java-22-openjdk-devel git curl wget
```

### Arch-based Systems

```bash
sudo pacman -S jdk-openjdk git curl wget
```

<img alt="prerequisites" src="https://raw.githubusercontent.com/crisa97/BurpSuiteLoaderGen/main/Media/prerequisites_linux.gif" width="500">

## Installation

### Automated Installation

To install Burp Suite Professional, run the following command (root user):

```bash
curl https://raw.githubusercontent.com/crisa97/BurpSuitePro/main/Linux/install.sh | sudo bash
```

Note: Make sure to enter your password after running this command as it is executed with root privileges.

<img alt="installation" src="https://raw.githubusercontent.com/crisa97/BurpSuiteLoaderGen/main/Media/installation_linux.gif" width="500">

### Manual Installation

If you prefer a manual installation, follow the steps below:

1. Clone the repository:

```bash
git clone https://github.com/crisa97/BurpSuitePro.git
```

2. Change the directory:

```bash
cd BurpSuitePro/Linux
```

3. Run the installation script:

```bash
sudo bash install.sh
```

## Usage

To run Burp Suite Professional, execute the following command:

```bash
burpsuitepro
```

<img alt="usage" src="https://raw.githubusercontent.com/crisa97/BurpSuiteLoaderGen/main/Media/usage_linux.gif" width="500">

## Uninstallation

### Automated Uninstallation

To uninstall Burp Suite Professional, run the following command (root user):

```bash
curl https://raw.githubusercontent.com/crisa97/BurpSuitePro/main/Linux/uninstall.sh | sudo bash
```

<img alt="uninstallation" src="https://raw.githubusercontent.com/crisa97/BurpSuiteLoaderGen/main/Media/uninstallation_linux.gif" width="500">

### Manual Uninstallation

1. Change the directory:

```bash
cd BurpSuitePro/Linux
```

2. Run the uninstallation script:

```bash
sudo bash uninstall.sh
```

## Update (Optional)

### Automated Update

To update Burp Suite Professional, run the following command (root user):

```bash
curl https://raw.githubusercontent.com/crisa97/BurpSuitePro/main/Linux/update.sh | sudo bash
```

### Manual Update

1. Change the directory:

```bash
cd BurpSuitePro/Linux
```

2. Run the update script:

```bash
sudo bash update.sh
```

![BurpSuiteProfessional](https://raw.githubusercontent.com/crisa97/BurpSuiteLoaderGen/main/Media/BurpSuitePro_1.png)
