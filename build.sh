tar -czf ${NAME}-${VERSION}.tar.gz log_collector.py log-collector.service log-collector.spec
#!/usr/bin/env bash
set -euo pipefail

PKG="log-collector"
VER="1.0"
SRCDIR="${PKG}-${VER}"
SRCTAR="${SRCDIR}.tar.gz"
TOPDIR="$(pwd)"
RPMBUILD_DIR="${HOME}/rpmbuild"

echo "Cleaning old artifacts..."
rm -rf "${SRCDIR}" "${SRCTAR}" dist gh-pages || true
mkdir -p dist gh-pages

echo "Preparing source directory ${SRCDIR}..."
rm -rf "${SRCDIR}"
mkdir -p "${SRCDIR}"
# Copy only the files needed for the package into the source dir
cp -p log_collector.py log-collector.service log-collector.spec README.md "${SRCDIR}/" || true

echo "Creating source tarball ${SRCTAR}..."
tar -czf "${SRCTAR}" "${SRCDIR}"

echo "Setting up rpmbuild directories under ${RPMBUILD_DIR}..."
mkdir -p "${RPMBUILD_DIR}"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

echo "Copying sources and spec..."
cp -p "${SRCTAR}" "${RPMBUILD_DIR}/SOURCES/"
cp -p log-collector.spec "${RPMBUILD_DIR}/SPECS/"

echo "Building RPM..."
rpmbuild -ba "${RPMBUILD_DIR}/SPECS/log-collector.spec"

echo "Collecting built RPM(s) into dist/..."
find "${RPMBUILD_DIR}/RPMS" -type f -name "${PKG}-*.rpm" -exec cp -p {} dist/ \; || true

echo "Copying RPM(s) to gh-pages/..."
cp -p dist/*.rpm gh-pages/ 2>/dev/null || true

echo "Generating gh-pages index..."
cat > gh-pages/index.html <<EOF
<!doctype html>
<html>
	<head>
		<meta charset="utf-8">
		<title>${PKG} RPMs</title>
	</head>
	<body>
		<h1>${PKG} RPMs</h1>
		<ul>
EOF

for f in gh-pages/*.rpm; do
	[ -e "$f" ] || continue
	filename=$(basename "$f")
	echo "      <li><a href=\"${filename}\">${filename}</a></li>" >> gh-pages/index.html
done

cat >> gh-pages/index.html <<EOF
		</ul>
	</body>
</html>
EOF

echo "Done. RPM(s) in dist/, static site in gh-pages/"