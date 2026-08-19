$ErrorActionPreference = 'Stop'

$PythonBin = if ($env:PYTHON_BIN) { $env:PYTHON_BIN } else { 'python' }

& $PythonBin tool/test_check_markdown_links.py
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $PythonBin tool/test_check_arb_catalogs.py
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $PythonBin tool/check_markdown_links.py .
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $PythonBin tool/check_arb_catalogs.py .
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
