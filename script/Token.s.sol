// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Vm.sol";
import "../src/EmptyContract.sol";
import "../src/Token.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {Script, console} from "forge-std/Script.sol";


contract TokenScript is Script {
    EmptyContract public emptyContract;
    Token public token;
    Token public tokenImplementation;
    ProxyAdmin public tokenProxyAdmin;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        vm.startBroadcast();

        emptyContract = new EmptyContract();
        TransparentUpgradeableProxy proxyToken = new TransparentUpgradeableProxy(address(emptyContract), deployerAddress, "");
        token = Token(payable(address(proxyToken)));
        tokenImplementation = new Token();
        tokenProxyAdmin = ProxyAdmin(getProxyAdminAddress(address(proxyToken)));
        tokenProxyAdmin.upgradeAndCall(
            ITransparentUpgradeableProxy(address(token)),
            address(tokenImplementation),
            abi.encodeWithSelector(
                Token.initialize.selector,
                msg.sender,
                10e40
            )
        );
        vm.stopBroadcast();

        console.log("token proxy contract deployed at:", address(token));
    }

    function getProxyAdminAddress(address proxy) internal view returns (address) {
        address CHEATCODE_ADDRESS = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D;
        Vm vm = Vm(CHEATCODE_ADDRESS);

        bytes32 adminSlot = vm.load(proxy, ERC1967Utils.ADMIN_SLOT);
        return address(uint160(uint256(adminSlot)));
    }
}
