# MCP Toolkit Gleam

Production-ready Model Context Protocol (MCP) Toolkit implementation in Gleam with comprehensive transport support, bidirectional communication, and enterprise-grade features.

## 🎯 Features

### Multi-Transport Support
- **stdio**: Standard input/output transport
- **WebSocket**: Real-time bidirectional communication on `ws://localhost:8080/mcp`
- **Server-Sent Events (SSE)**: Server-to-client streaming on `http://localhost:8081/mcp`
- **Transport Bridging**: Connect any two transports with filtering and transformation

### Production-Ready Architecture
- **Latest MCP Specification**: Implements MCP 2025-06-18 with backward compatibility
- **Comprehensive Testing**: Full test coverage with birdie snapshots and gleunit (71+ tests)
- **Type Safety**: Strong typing throughout with comprehensive error handling
- **Modular Design**: Clean separation between core protocol and transport layers
- **Production-Ready**: Comprehensive error handling and logging throughout

### Enterprise Features
- Bidirectional communication with server-initiated requests
- Resource/tool/prompt change notifications
- Request/response correlation with unique IDs
- Client capability tracking and message routing
- Comprehensive logging and error reporting

## 🚀 Quick Start

### Prerequisites

- **Erlang/OTP 27+**: Required for gleam_json 3.x and latest features
- **Gleam 1.12.0+**: Latest Gleam compiler with modern language features
- **Git**: For version control and dependency management

### Installation

```bash
gleam deps download
gleam build
```

### Usage Examples

```bash
# Lightweight stdio transport (dependency-free)
gleam run -m mcp_stdio_server

# Full server with WebSocket support
gleam run -m mcp_full_server websocket

# Full server with Server-Sent Events
gleam run -m mcp_full_server sse

# Transport bridging between different protocols
gleam run -m mcp_full_server bridge

# Comprehensive server with all transports
gleam run -m mcp_full_server full
```

## 📁 Project Structure

```
src/
├── mcp_stdio_server.gleam        # Lightweight stdio executable
├── mcp_full_server.gleam         # Comprehensive server executable  
└── mcp_toolkit_gleam/
    ├── core/                   # Core protocol implementation
    │   ├── protocol.gleam      # MCP protocol types and functions
    │   ├── server.gleam        # Server implementation
    │   ├── method.gleam        # MCP method constants
    │   └── json_schema*.gleam  # JSON schema handling
    ├── transport/              # Core transports
    │   └── stdio.gleam         # Standard I/O transport
    └── transport_optional/     # HTTP/WebSocket transports
        ├── websocket.gleam     # WebSocket transport
        ├── sse.gleam          # Server-Sent Events transport
        ├── bidirectional.gleam # Bidirectional communication
        └── bridge.gleam        # Transport bridging

test/
├── mcp_toolkit_gleam/
│   ├── core/                   # Core functionality tests
│   ├── transport/              # Transport layer tests
│   ├── transport_optional/     # Optional transport tests
│   └── integration/           # End-to-end integration tests
└── birdie_snapshots/          # Snapshot test data
```

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   MCP Client    │◄──►│  Transport Layer │◄──►│   MCP Server    │
│                 │    │                  │    │                 │
│  • Claude       │    │  • stdio         │    │  • Resources    │
│  • VS Code      │    │  • WebSocket     │    │  • Tools        │
│  • Custom App   │    │  • SSE           │    │  • Prompts      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                       ┌──────▼──────┐
                       │   Bridge    │
                       │             │
                       │ • Filter    │
                       │ • Transform │
                       │ • Route     │
                       └─────────────┘
```

## 🧪 Testing

The project includes comprehensive testing with birdie snapshots and gleunit:

```bash
# Run all tests
gleam test

# Run specific test modules
gleam test --module mcp_toolkit_gleam/core/protocol_test
gleam test --module mcp_toolkit_gleam/integration/full_test
```

Note: Test coverage reporting requires additional tooling. The project currently has 71 comprehensive tests covering core protocol, server, transport, and integration functionality.

### Test Categories
- **Unit Tests**: Individual component testing with gleunit
- **Snapshot Tests**: JSON serialization testing with birdie
- **Integration Tests**: End-to-end functionality testing
- **Transport Tests**: Protocol compliance and error handling

## 📋 MCP Protocol Compliance

### Supported MCP Versions
- **2025-06-18** (Latest specification)
- **2025-03-26** (Backward compatible)
- **2024-11-05** (Backward compatible)

### Implemented Features
- ✅ Resource management with subscriptions
- ✅ Tool execution with error handling
- ✅ Prompt templates with parameters
- ✅ Bidirectional communication
- ✅ Server-initiated notifications
- ✅ Client capability negotiation
- ✅ Comprehensive logging support
- ✅ Progress tracking

## 🔧 Dependencies

### Core Dependencies
```toml
# Core protocol dependencies
gleam_stdlib = ">= 0.44.0 and < 2.0.0"
gleam_http = ">= 4.0.0 and < 5.0.0"
gleam_json = ">= 3.0.0 and < 4.0.0"  # Requires Erlang/OTP 27+
justin = ">= 1.0.1 and < 2.0.0"
gleam_erlang = ">= 1.0.0 and < 2.0.0"

# Note: jsonrpc is vendored internally for compatibility with gleam_json 3.x
```

### Development Dependencies
```toml
gleeunit = ">= 1.0.0 and < 2.0.0"
birdie = ">= 1.2.7 and < 2.0.0"
argv = ">= 1.0.2 and < 2.0.0"
simplifile = ">= 2.2.1 and < 3.0.0"
```

## 🚦 Production Deployment

### Docker Deployment
```dockerfile
FROM gleam:latest
WORKDIR /app
COPY . .
RUN gleam deps download
RUN gleam build
EXPOSE 8080 8081
CMD ["gleam", "run", "--", "mcpserver", "full"]
```

### Environment Configuration
```bash
# Configure logging
export MCP_LOG_LEVEL=info
export MCP_LOG_FORMAT=json

# Configure transports
export MCP_WEBSOCKET_PORT=8080
export MCP_SSE_PORT=8081

# Configure security
export MCP_CORS_ENABLED=true
export MCP_AUTH_ENABLED=false
```

## 🔒 Security

### Security Features
- Input validation on all protocol messages
- JSON schema validation for tool parameters
- Request size limits and rate limiting
- CORS support for web clients
- Comprehensive error handling without information leakage

### Security Best Practices
- Run with minimal privileges
- Use TLS for production WebSocket/SSE transports
- Implement authentication for sensitive resources
- Monitor and log all protocol interactions

## 🤝 Contributing

### Development Setup
```bash
git clone https://github.com/mikkihugo/mcp_toolkit_gleam.git
cd mcp_toolkit_gleam
gleam deps download
gleam test
```

### Code Quality
- All code must pass `gleam format`
- Comprehensive test coverage (71+ tests)
- Comprehensive documentation for public APIs
- Security review for transport implementations

## 📄 License

Apache-2.0 License. See [LICENSE](LICENSE) for details.

## 🔗 Links

- [Model Context Protocol Specification](https://modelcontextprotocol.io/specification/2025-06-18/)
- [Gleam Language](https://gleam.run/)
- [MCP SDK Documentation](https://github.com/modelcontextprotocol)

---

**MCP Toolkit Gleam** - Enterprise-grade Model Context Protocol implementation for production systems.