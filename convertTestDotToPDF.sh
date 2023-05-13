shopt -s nullglob

TESTFOLDER="./testsResults/tests"
MYTESTFOLDER="./testsResults/myTests"

PDFFOLDER="./testsResults/tests/pdf"
MYPDFFOLDER="./testsResults/myTests/pdf"

echo "Removing old pdf files..."

if [ -d "$PDFFOLDER" ]; then
    rm -rf "$PDFFOLDER"
fi

if [ -d "$MYPDFFOLDER" ]; then
    rm -rf "$MYPDFFOLDER"
fi

mkdir -p "$TESTFOLDER/pdf"
mkdir -p "$MYTESTFOLDER/pdf"

echo "Converting dot files to pdf..."
for file in $TESTFOLDER/*; do
    [ -f "$file" ] || continue
    f=$(echo "${file##*/}");
    filename=$(echo $f| cut  -d'.' -f 1);
    echo "Processing $file..."
    dot -Tpdf "$file" -o "$PDFFOLDER/$filename.pdf"
done

for file in $MYTESTFOLDER/*; do
    [ -f "$file" ] || continue
    f=$(echo "${file##*/}");
    filename=$(echo $f| cut  -d'.' -f 1);
    echo "Processing $file..."
    dot -Tpdf "$file" -o "$MYPDFFOLDER/$filename.pdf"
done

echo "Done!"