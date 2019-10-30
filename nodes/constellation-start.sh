#!/bin/bash
set -u
set -e

numNodes=7
if [[ -f qdata/numberOfNodes ]]; then
    numNodes=`cat qdata/numberOfNodes`
fi

echo "[*] Starting $numNodes Constellation node(s)"

INDEX_NODE=$(cat ~/node_config | grep "NODE_INDEX" | awk -F '=' '{print $2}')

DDIR="qdata/c$INDEX_NODE"
mkdir -p $DDIR
mkdir -p qdata/logs
cp "keys/tm$INDEX_NODE.pub" "$DDIR/tm.pub"
cp "keys/tm$INDEX_NODE.key" "$DDIR/tm.key"
rm -f "$DDIR/tm.ipc"
CMD="constellation-node --url=https://127.0.0.$INDEX_NODE:900$INDEX_NODE/ --port=900$INDEX_NODE --workdir=$DDIR --socket=tm.ipc --publickeys=tm.pub --privatekeys=tm.key --othernodes=https://127.0.0.1:9001/"
echo "$CMD >> qdata/logs/constellation$INDEX_NODE.log 2>&1 &"
nohup $CMD >> "qdata/logs/constellation$INDEX_NODE.log" 2>&1 &

DOWN=true
while $DOWN; do
    sleep 0.1
    DOWN=false
    if [ ! -S "qdata/c$INDEX_NODE/tm.ipc" ]; then
      DOWN=true
    fi
done
