# Overwatch Framework

Overwatch is a modular Garry's Mod roleplay framework developed by [Riggs](https:/github.com/riggs9162) and [bloodycop](https:/github.com/bloodycop6385) following the closure of Minerva Servers. It is designed to faithfully capture and modernize the gameplay behavior of **Project Synapse** and **impulse**, offering a modern, immersive, and technically sound roleplay experience.

## Vision

Overwatch is more than a framework, it's a foundation for expressive scalable roleplay servers. Our goal is to build a system that offers:

- **Clean, modular architecture** – Easy to extend, safe to modify.
- **Modern UX standards** – A polished, intuitive player experience with a UI inspired by the iconic Half-Life 2 Gamepad interface.
- **Robust backend systems** – Secure, compressed, and encrypted data pipelines.
- **Flexible schema development** – Tools and standards for custom server creation.

We are also developing advanced schema concepts internally to support a range of gameplay environments, including lore-based and lore-agnostic roleplay—details on these will be revealed in time.

## Core Repositories

- **Skeleton Schema** – Provides the structural baseline and shared systems used across all schemas.
- *(Private schemas are in development and integrate seamlessly with the framework.)*

## Custom Libraries

### `ow.crypto`
> Pure Lua library for length-prefixed serialization, compression, and encryption.  
> Ensures clean data transmission with no ambiguous delimiters. Core to all networked communication.

### `ow.relay`
> A high-level data syncing layer powered by `ow.crypto`.  
> Offers per-player, per-entity, and shared scopes for seamless value replication.

### `ow.sqlite`
> A flexible SQLite abstraction for dynamic variable and row registration.  
> Built to support persistent data layers like users, characters, and inventory systems.

## Development Team

- **[Riggs](https:/github.com/riggs9162)** – Co-founder, lead UI designer & programmer, core framework developer, backend engineer.  
- **[bloodycop](https:/github.com/bloodycop6385)** – Co-founder, backend engineer, quality-of-life systems designer, contributor to core systems.

## Status

> 🚧 **In Active Development** — Not yet public. Initial testing is underway.

Stay tuned for more.