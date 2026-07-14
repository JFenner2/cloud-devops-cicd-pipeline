#!/bin/bash

set -euo pipefail

dnf update -y
dnf install -y docker

systemctl enable --now docker
systemctl enable --now amazon-ssm-agent

usermod -aG docker ec2-user
