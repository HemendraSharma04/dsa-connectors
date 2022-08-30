//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import { DSMath } from "../../common/math.sol";
import { Basic } from "../../common/basic.sol";
import { CometInterface } from "./interface.sol";

abstract contract Helpers is DSMath, Basic {
	function getBaseToken(address market)
		internal
		view
		returns (address baseToken)
	{
		baseToken = CometInterface(market).baseToken();
	}

	function _supply(
		address market,
		address token,
		address from,
		address to,
		uint256 amt
	) internal payable returns (bool success) {
		bytes memory data;

		if (from == address(0) && to == address(0)) {
			data = abi.encodeWithSignature(
				"supply(address, uint256)",
				token,
				amt
			);
		} else if (from == address(0)) {
			data = abi.encodeWithSignature(
				"supplyTo(address, address, uint256)",
				to,
				token,
				amt
			);
		} else if (from != address(0) && to != address(0)) {
			data = abi.encodeWithSignature(
				"supplyFrom(address, address, address, uint256)",
				from,
				to,
				token,
				amt
			);
		}

		(success, ) = market.delegateCall(data);
	}

	function _withdraw(
		address market,
		address token,
		address from,
		address to,
		uint256 amt
	) internal payable returns (bool success) {
		bytes memory data;

		if (from == address(0) && to == address(0)) {
			data = abi.encodeWithSignature(
				"withdraw(address, uint256)",
				token,
				amt
			);
		} else if (from == address(0)) {
			data = abi.encodeWithSignature(
				"withdrawTo(address, address, uint256)",
				to,
				token,
				amt
			);
		} else if (from != address(0) && to != address(0)) {
			data = abi.encodeWithSignature(
				"withdrawFrom(address, address, address, uint256)",
				from,
				to,
				token,
				amt
			);
		}
		(success, ) = market.delegateCall(data);
	}

	function getAccountSupplyBalanceOfAsset(
		address account,
		address market,
		address asset
	) internal view returns (uint256 balance) {
		if (asset == getBaseToken(market)) {
			//balance in base
			balance = CometInterface(market).balanceOf(account);
		} else {
			//balance in asset denomination
			balance = uint256(
				CometInterface(market).userCollateral(account, asset).balance
			);
		}
	}
}
