# Amalgam&trade; Build Container - Linux

Linux container for building the [Amalgam](https://github.com/howsoai/amalgam) language interpreter.

## Building

To build the default Amalgam Linux Build Container for the host architecture
```bash
docker build -t amalgam-build-container-linux .
```

The released image is a multi-arch manifest (`linux/amd64` and `linux/arm64`) so that each
Amalgam architecture is built natively on a runner of the same architecture. To reproduce
that locally:
```bash
docker buildx build --platform linux/amd64,linux/arm64 -t amalgam-build-container-linux .
```

Note: the Emscripten SDK is only installed in the `amd64` image, since `wasm64` is only
ever built on `amd64`.

To build the Oracle Linux 8.x Container to support GLIBC 2.28 (`amd64` only)
```bash
docker build -f linux-228/Dockerfile -t amalgam-build-container-linux-228 .
```

## License

[License](LICENSE.txt)

## Contributing

[Contributing](CONTRIBUTING.md)