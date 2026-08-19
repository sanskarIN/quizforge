# Security Tooling and Triage

QuizForge uses several complementary security controls. No single scanner is treated as proof that the application is secure.

## Source and dependency controls

### Flutter analyzer

`flutter analyze` is the first source-level correctness/static-analysis gate for the Dart/Flutter application. Analyzer warnings/errors must be reviewed rather than broadly suppressed.

### Dependency review

Pull requests are checked for newly introduced dependency risk. Dependency changes should remain small enough to review package purpose, transitive impact, license/security signals, and platform permissions.

### OSV scanning

The tracked OSV workflow scans package-lock state on its configured triggers. A finding must be triaged by affected package/version/reachability and fixed by update/removal/mitigation as appropriate.

### Dependabot

Dependabot opens dependency update proposals. Automated update creation is not automated trust: every update still passes normal review and CI.

### Secret scanning

The `Secret Scan` workflow checks repository history and the working tree with Gitleaks. GitHub repository secret scanning/push protection should also be enabled in repository settings where available.

A scan result must never be “fixed” by adding a broad ignore rule before confirming it is a false positive. If a real credential was committed, deleting the string from a later commit is not sufficient—rotate/revoke the credential first, then clean history if appropriate.

## Application controls

The current product additionally uses:

- offline-first architecture;
- explicit import validation;
- duplicate handling;
- transactional persistence;
- foreign-key enforcement;
- user-safe error messages;
- structured logging with sensitive/user-content redaction;
- fixed application-owned external links;
- a disabled-by-default multiplayer network boundary;
- explicit privacy, threat-model, and responsible-disclosure documentation.

## Security triage order

When a security workflow fails:

1. Preserve the finding/log without publishing secrets.
2. Identify whether the finding is real, a dependency advisory, or a scanner false positive.
3. If a credential may be exposed, revoke/rotate it outside the repository immediately.
4. Determine affected releases/branches and user impact.
5. Fix the underlying issue with the smallest safe change.
6. Add regression coverage where technically meaningful.
7. Re-run the relevant scanner plus the normal quality/build suite.
8. Update `SECURITY.md`, release notes, and user guidance when disclosure or upgrading is required.

## Networking changes

Before enabling a future private-room implementation or adding any cloud feature, update:

- `docs/threat-model.md`;
- `PRIVACY.md`;
- `docs/data-lifecycle.md`;
- the relevant ADR;
- automated abuse/input/protocol tests;
- release/security documentation.

Do not enable networking first and treat the security review as post-release cleanup.
