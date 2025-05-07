# Token

A Solidity smart contract project to **create, customize, and deploy** your own ERC-20 tokens on Ethereum.

## Build
```shell
$ forge build
```

## Env
```shell
Get-Content .env | ForEach-Object {
    if ($_ -match "^\s*([^#]\S+)\s*=\s*(.*)\s*$") {
        $varName = $matches[1]
        $varValue = $matches[2] -replace '^"|"$|^''|''$'  # 去除可能的引号
        Set-Item -Path "env:$varName" -Value $varValue
    }
}

echo $env:PRIVATE_KEY
echo $env:RPC_URL
```

## Deploy
```shell
forge script ./script/Token.s.sol:TokenScript --rpc-url $env:RPC_URL --private-key $env:PRIVATE_KEY --broadcast
```

## Address
```
token proxy contract deployed at: 0xB33CE01d6242c73eB318661Cf0eeE8Ace7680b33
```
