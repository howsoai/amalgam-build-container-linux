# Amalgam&trade; Build Container - Linux

Linux container for building the [Amalgam](https://github.com/howsoai/amalgam) language interpreter.

## Building

To build the default Amalgam Linux Build Container
```bash
docker build -t amalgam-build-container-linux .
```

To build the Oracle Linux 8.x Container to support GLIBC 2.28
```bash
docker build -f linux-228/Dockerfile -t amalgam-build-container-linux-228 .
```

## License

[License](LICENSE.txt)

## Contributing

[Contributing](CONTRIBUTING.md)