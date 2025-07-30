# Crossplane Functions by Language

This repository demonstrates how to implement the same Crossplane composition function in different programming languages. 
It showcases the flexibility of Crossplane's function-based composition approach by implementing an encryption key management solution using Go, Go templates, KCL, and CUE.

## Overview

The project implements a custom resource called `XEncryptionKey` that creates a Google Cloud Platform (GCP) KMS CryptoKey with a specified protection level.
The same functionality is implemented using different Crossplane function languages:

- **Go**: Native Go implementation using the [Crossplane Function SDK](https://github.com/crossplane/function-sdk-go)
- **Go Templates**: Implementation using Go templates
- **KCL**: Implementation using the [KCL](https://www.kcl-lang.io) configuration language
- **CUE**: Implementation using the [CUE](http://cuelang.org) configuration language
- TODO: **Python**: Implementation using the [Python Function SDK](https://github.com/crossplane/function-sdk-python)

Each implementation achieves the same result but demonstrates the different approaches and syntax of each language.
I focused intentionally on a super simple setup.

## Prerequisites

To use this project, you need:

- [Upbound CLI](https://docs.upbound.io/cli/) installed
- Upbound account to pull packages with Up CLI (?)

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/sijoma/crossplane-functions-by-language.git
   cd crossplane-functions-by-language
   ```

2. Build the project:
   ```
   make build
   ```

3. Apply the XEncryptionKey definition:
   ```
   kubectl apply -f apis/xencryptionkeys/definition.yaml
   ```

4. Apply the composition of your choice:
   ```
   # For Go implementation
   kubectl apply -f apis/xencryptionkeys/go-composition.yaml
   
   # For Go Templates implementation
   kubectl apply -f apis/xencryptionkeys/go-tmpl-composition.yaml
   
   # For KCL implementation
   kubectl apply -f apis/xencryptionkeys/kcl-composition.yaml
   
   # For CUE implementation
   kubectl apply -f apis/xencryptionkeys/cue-composition.yaml
   ```


## Implementation Details

### Go Implementation

The Go implementation uses the Crossplane Function SDK to create a GCP KMS CryptoKey. It extracts the protection level from the XEncryptionKey spec and creates a CryptoKey with the specified protection level.

Key files:
- `functions/go-encryption/fn.go`: Main function implementation
- `apis/xencryptionkeys/go-composition.yaml`: Composition definition

### Go Templates Implementation

The Go Templates implementation uses Go templates to generate the desired resources. It provides a more declarative approach compared to the Go implementation.

Key files:
- `functions/go-tmpl-encryption/`: Template files
- `apis/xencryptionkeys/go-tmpl-composition.yaml`: Composition definition

### KCL Implementation

The KCL implementation uses the KCL configuration language to define the desired resources. KCL provides a more concise syntax with built-in validation.

Key files:
- `functions/kcl-encryption/main.k`: Main KCL implementation
- `apis/xencryptionkeys/kcl-composition.yaml`: Composition definition

### CUE Implementation

The CUE implementation uses the CUE configuration language to define the desired resources. CUE provides strong typing and validation capabilities.

Key files:
- `apis/xencryptionkeys/cue-composition.yaml`: Composition definition

## Testing

The project includes tests for all implementations:

```
# Run all tests
make test

# Run end-to-end tests
make test-e2e
```

You can also render the compositions to see the resulting resources:

```
# Render all compositions
make render
```

The rendered outputs are saved in the `golden` directory.

## Usage

1. Create an XEncryptionKey resource using one of the example files:
   ```
   # For Go implementation
   kubectl apply -f examples/go-xencryptionkey.yaml
   
   # For Go Templates implementation
   kubectl apply -f examples/go-tmpl-xencryptionkey.yaml
   
   # For KCL implementation
   kubectl apply -f examples/kcl-xencryptionkey.yaml
   
   # For CUE implementation
   kubectl apply -f examples/cue-xencryptionkey.yaml
   ```

2. Check the status of your XEncryptionKey:
   ```
   kubectl get xencryptionkeys
   ```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. I didnt implement the Python function yet!
