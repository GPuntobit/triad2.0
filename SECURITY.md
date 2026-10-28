# Security policy

Triad accepts security reports about the language implementations and the tools
in this repository. Please report suspected vulnerabilities privately. Do not
publish technical details until the maintainer and reporter have agreed on
disclosure.

## Supported versions

Security fixes are intended for the latest published release and the current
default branch. Earlier beta releases may not receive fixes. When reporting an
issue, include the exact release or commit you tested.

The version in [`VERSION`](VERSION) identifies the language specification; it
is not the version of a repository release.

## Reporting a vulnerability

If GitHub offers **Report a vulnerability** on the repository's Security tab,
use that private reporting form.

If private reporting is unavailable, do not post the vulnerability details in a
public issue, pull request, or discussion. Open an issue with only a short
request for a private reporting channel. Do not include proof-of-concept code,
affected files, logs, or other technical details in that public request. Share
the report only after the maintainer provides a private channel.

Include what you know from this list:

- The affected release or commit, operating system, and runtime.
- The component and conditions needed to trigger the issue.
- The security impact and who could be affected.
- A minimal reproduction or proof of concept, shared privately.
- Any workaround you have identified.

Remove credentials, personal information, and unrelated user data from reports
and logs. Do not access, modify, or retain data that is not yours while
investigating.

## What to expect

The maintainer will review the report, may ask for details needed to confirm its
impact, and will coordinate with the reporter before public disclosure when
possible. There is no guaranteed response or resolution time, and the project
does not currently promise a bug bounty.

Please allow time for investigation and a fix before publishing details. If a
report is not a security issue, the maintainer may ask that it be filed as a
regular issue after sensitive information has been removed.

## Scope

Reports are in scope when they demonstrate a security impact in Triad's
repository, including its interpreters and seeds, command-line tools, build or
release workflows, and maintained dependencies as used by the project.

Reports without a clear security impact, general feature requests, and issues
that exist only in unrelated third-party software are not security
vulnerabilities in this project. If the behavior depends on an external
component, explain how Triad or this repository exposes or relies on it.
