# Crypto Wine Inventory 🍷⛓️

**A blockchain registry that gives every wine bottle a permanent, tamper-proof history from grape to glass — so a counterfeit can never pass as the real thing.**

Assignment 5 — Crypto / Blockchain App. This repo is the practical part: a real
smart contract plus a zero-install browser demo, deliverable entirely through GitHub.

[**▶ Live demo**](https://vich1003.github.io/Crypto-wine-inventory/) 

---

## The problem this solves

Fine wine is one of the most counterfeited luxury goods in the world. The most
famous case, Rudy Kurniawan (the *Sour Grapes* documentary), saw millions of
dollars of fake bottles sold at auction because **paper labels and provenance
can be forged**. There is no shared, trustworthy record of where a bottle has
actually been.

A blockchain fixes exactly this: a **decentralised, permanent, timestamped
ledger** that no single party can rewrite. Register a bottle at the winery, and
every later step — bottling, shipping, storage, sale — is appended as a linked,
hashed block. A buyer scans the QR code and instantly sees the whole verified
journey. A fake has no such record.

## How the 8 supply-chain actors become 3 actions

The brief lists eight participants (producer, winery, importer, distributor,
wholesaler, broker, retailer, customer). On a blockchain they are **not** eight
different systems — that would just be eight screens. They collapse into three
actions on one shared ledger, which is the actual insight:

| Role in the demo | Brief actors it covers | What they do on-chain |
|---|---|---|
| **Producer** | producer, winery | `registerBottle` + log production events |
| **Trade** | importer, distributor, wholesaler, broker, retailer | `addEvent` (logistics) + `transferOwnership` |
| **Customer** | consumer, collector | verify (read) + receive ownership on purchase |

The chain doesn't care *who* an address belongs to — it records *what action*
was taken, permanently. That single shared ledger **is** the supply-chain
transparency the brief asks for.

## What's in this repo

```
crypto-wine-inventory/
├── index.html                  # the clickable demo (this is the GitHub Pages site)
├── contracts/
│   └── WineProvenance.sol       # the real Solidity smart contract
└── README.md
```

### `contracts/WineProvenance.sol` — the real blockchain logic
A Solidity contract with three core functions mirroring the three actions above:
`registerBottle`, `addEvent`, `transferOwnership`, plus read functions
(`getBottle`, `getEvent`, `isRegistered`) for verification. Ownership transfers
are guarded so only the current owner can pass a bottle on — that's the on-chain
chain-of-custody. It compiles cleanly on Solidity `^0.8.19`.

### `index.html` — the browser demo
A self-contained Material-Design page that runs a **simulated blockchain** in
JavaScript: each block is SHA-256 hashed and linked to the previous one, exactly
like a real chain. You can switch between the three roles, register bottles, move
them through the supply chain, and verify authenticity. The **"simulate a forger
editing a record"** button shows the key property: alter one block and every
downstream hash breaks, so the tampering is caught and the bottle is rejected.
Seeded with real wines (Keller, Rebholz, Bürklin-Wolf) from the project brief.

> Why both? The Solidity contract is the authentic on-chain logic a blockchain
> course wants to see; the browser demo lets anyone open one link and watch it
> work without installing a wallet.

## Run it

**Just the demo:** open `index.html` in any browser. That's it.

**Publish it on GitHub Pages:**
1. Push this folder to a GitHub repository.
2. Repo → **Settings → Pages** → Source: *Deploy from a branch* → `main` / root.
3. GitHub gives you a public URL; paste it under "Live demo" above.

**Try the real contract (optional):** paste `WineProvenance.sol` into
[Remix](https://remix.ethereum.org), compile with 0.8.x, and deploy to a test
network (e.g. Sepolia) with MetaMask. Call `registerBottle`, then `addEvent` and
`transferOwnership`, and read the history back with `getBottle` / `getEvent`.

## Concept demo script (for the presentation)

1. As **Producer**, register a Wittmann bottle → genesis block appears.
2. As **Trade**, add "Shipped to retailer" and transfer ownership → blocks chain on.
3. As **Customer**, verify the bottle → ✓ AUTHENTIC, full grape-to-glass timeline.
4. Hit **simulate a forger** → chain breaks, bottle is rejected. *That* is why
   blockchain stops wine fraud.

---

*Built for a cryptocurrency & blockchain course. Scope is deliberately minimal —
the focus is the blockchain mechanism, not a full production app.*
