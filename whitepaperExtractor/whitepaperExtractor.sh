#!/bin/bash

thisScript=$(readlink -f $0)
myPath=$(dirname $thisScript)

if [ $# -gt 0 ]
then
    basePath=$1
else
    basePath=$myPath
fi

txId="54e48e5f5c656b26c3bca14a8c95aa583d07ebe84dde3b7dd4a78f4e4186e713"
maxOutId=945
pdfFile="$basePath/bitcoin.pdf"
hexFile="$basePath/bitcoin.hex"
rm -f $hexFile
rm -f $pdfFile

echo "extracting bitcoin whitepaper to [$pdfFile]..."

for outId in $(seq 0 $maxOutId)
do
    echo "Output $outId processed."
    ret=($(bitcoin-cli gettxout $txId $outId | jq .scriptPubKey.asm))
    partId=0
    for part in ${ret[@]}
    do
        if [ $partId -eq 1 -o $partId -eq 2 -o $partId -eq 3 ]
        then
            if [ $outId -eq 0 -a $partId -eq 1 ]
            then
                part="${part:16}"
            fi
            echo $part >> $hexFile
        fi
        partId=$((partId + 1))
    done
done
xxd -r -p $hexFile $pdfFile
echo "Done."
echo "PDF: $pdfFile"
