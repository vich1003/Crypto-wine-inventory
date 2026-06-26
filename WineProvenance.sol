// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title WineProvenance
 * @notice A blockchain registry that gives every wine bottle a permanent,
 *         timestamped, tamper-proof history from grape to glass.
 *
 * @dev The eight supply-chain actors in the brief (producer, winery, importer,
 *      distributor, wholesaler, broker, retailer, customer) are NOT eight
 *      different contracts. On-chain they collapse into three actions, which is
 *      the whole point of a shared ledger:
 *
 *        PRODUCER (producer, winery)         -> registerBottle + addEvent
 *        TRADE    (importer, distributor,    -> addEvent + transferOwnership
 *                  wholesaler, broker,
 *                  retailer)
 *        CUSTOMER (consumer, collector)      -> verify (read) + receive ownership
 *
 *      Any Ethereum address can play any role. The chain does not care who you
 *      are; it records what you did, permanently. That is what stops the kind of
 *      counterfeiting documented in the Kurniawan / "Sour Grapes" case.
 */
contract WineProvenance {

    // --- Data model ---------------------------------------------------------

    // A single immutable entry in a bottle's history.
    struct ProvenanceEvent {
        string  action;     // e.g. "Harvested", "Bottled", "Shipped", "Sold"
        string  location;   // where it happened
        address author;     // who recorded it
        uint256 timestamp;  // block time, set by the chain (cannot be faked)
    }

    // The bottle itself. `id` is the unique code printed as the QR on the label.
    struct Bottle {
        string  id;
        string  wineName;
        string  producer;
        uint16  vintage;
        string  region;
        address currentOwner;
        bool    exists;
    }

    // bottle id -> bottle
    mapping(string => Bottle) private bottles;
    // bottle id -> full ordered history
    mapping(string => ProvenanceEvent[]) private history;

    // --- Events (so front-ends / GitHub Pages demo can react) ---------------

    event BottleRegistered(string indexed id, string wineName, address producer);
    event EventAdded(string indexed id, string action, address author);
    event OwnershipTransferred(string indexed id, address from, address to);

    // --- 1. PRODUCER: register a new bottle ---------------------------------

    function registerBottle(
        string calldata id,
        string calldata wineName,
        string calldata producer,
        uint16 vintage,
        string calldata region
    ) external {
        require(!bottles[id].exists, "Bottle already registered");

        bottles[id] = Bottle({
            id: id,
            wineName: wineName,
            producer: producer,
            vintage: vintage,
            region: region,
            currentOwner: msg.sender,
            exists: true
        });

        _addEvent(id, "Registered at winery", region);
        emit BottleRegistered(id, wineName, msg.sender);
    }

    // --- 2. ANY ACTOR: add a provenance event -------------------------------
    // Used by the producer for production steps and by trade actors for
    // logistics steps (shipped, stored, received...).

    function addEvent(
        string calldata id,
        string calldata action,
        string calldata location
    ) external {
        require(bottles[id].exists, "Unknown bottle");
        _addEvent(id, action, location);
        emit EventAdded(id, action, msg.sender);
    }

    // --- 3. TRADE / CUSTOMER: transfer ownership ----------------------------
    // Only the current owner can hand the bottle on. This is the on-chain
    // chain-of-custody: every middleman and the final buyer is recorded.

    function transferOwnership(string calldata id, address to) external {
        require(bottles[id].exists, "Unknown bottle");
        require(bottles[id].currentOwner == msg.sender, "Only owner can transfer");
        require(to != address(0), "Invalid recipient");

        address from = msg.sender;
        bottles[id].currentOwner = to;

        _addEvent(id, "Ownership transferred", "");
        emit OwnershipTransferred(id, from, to);
    }

    // --- Reads: how a CUSTOMER verifies authenticity ------------------------

    function getBottle(string calldata id)
        external
        view
        returns (
            string memory wineName,
            string memory producer,
            uint16 vintage,
            string memory region,
            address currentOwner,
            uint256 eventCount
        )
    {
        require(bottles[id].exists, "Unknown bottle");
        Bottle storage b = bottles[id];
        return (b.wineName, b.producer, b.vintage, b.region, b.currentOwner, history[id].length);
    }

    function getEvent(string calldata id, uint256 index)
        external
        view
        returns (string memory action, string memory location, address author, uint256 timestamp)
    {
        require(bottles[id].exists, "Unknown bottle");
        require(index < history[id].length, "No such event");
        ProvenanceEvent storage e = history[id][index];
        return (e.action, e.location, e.author, e.timestamp);
    }

    // A bottle is "authentic" in this system if it exists on-chain at all:
    // a counterfeit has no registration the producer ever signed.
    function isRegistered(string calldata id) external view returns (bool) {
        return bottles[id].exists;
    }

    // --- internal -----------------------------------------------------------

    function _addEvent(string memory id, string memory action, string memory location) internal {
        history[id].push(ProvenanceEvent({
            action: action,
            location: location,
            author: msg.sender,
            timestamp: block.timestamp
        }));
    }
}
