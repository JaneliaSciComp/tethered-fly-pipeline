export const createHostsEntry = `
name: CreateHostsEntry
description: this document installs basic packages on Amazon Linux 2
schemaVersion: 1.0
parameters:
  - HostEntry:
      type: string
      description: Entry to be put in /etc/hosts.
phases:
  - name: build
    steps:
      - name: CreateHostsEntry
        action: ExecuteBash
        inputs:
          commands:
            - echo -e '{{HostEntry}}' | tee -a /etc/hosts
`
