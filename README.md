# `api` #

## Usage ##

```bash
npm install .

npm run start
```

# SSH Tunneling #

## Document-DB ##

### Local Connections ###

1. Create SSH Tunnel
    ```bash
    ssh -L localhost:27017:document-db.abc.us-east-2.docdb.amazonaws.com:27017 ec2-user@bastion.organization.io -i ~/.ssh/bastion-key.pem -N
    ```
    - Command Breakdown
        - Proxy-Forwarding (`ssh -L 27017:document-db.abc.us-east-2.docdb.amazonaws.com:27017`):
            - `ssh`: `openssh` executable application binary interface (abi)
            - `-L`: Specifies that connections to the given TCP port or Unix socket on the local (client) host are to be
              forwarded to the given host and port, or Unix socket, on the remote side; by allocating a socket to listen
              to either a TCP port on the local side,
              optionally bound to the specified bind_address, or to a Unix socket. Whenever a connection is made to the
              local port or socket, the connection is forwarded over the secure channel, and a connection is made to
              either host port hostport, or the Unix socket
              remote_socket, from the remote machine
            - `localhost` (Optional): Local hostname (used when connecting programmatically)
            - `27017`: Local port (used when connecting programmatically)
            - `document-db.abc.us-east-2.docdb.amazonaws.com`: AWS RDS server-name
            - `27017`: AWS RDS document-db service port
        - Tunnel Establishment (`ec2-user@bastion.organization.io -i ~/.ssh/bastion-key.pem`)
            - `ec2-user`: Username to connect to bastion. Often, in the case with AWS infrastructure, `ec2-user` is the
              default username
            - `bastion.organization.io`: The bastion's resolvable hostname
            - `-i`: Identity key file; the private ssh key used to establish a secure connection to the bastion server
            - `~/.ssh/bastion-key.pem`: The location to the private ssh filename
        - (`-N`)
            - Honestly, the `-N` flag is one of the most important parts. The purpose is to instruct the process to not
              forward any remote command(s)
2. Install CA-Certificate
    ```bash
    wget https://truststore.pki.rds.amazonaws.com/us-east-2/us-east-2-bundle.pem
    ```
3. Connect
    ```bash
    mongosh localhost --tls --tlsCAFile us-east-2-bundle.pem --tlsAllowInvalidHostnames
    ```

*Note* - Step 1 can be used for local development-related purposes, too.

- And in large, enterprise environments, ***often it's a requirement(s)***. It's not at all difficult.
  However, internal solutions to such a problem... unfortunately almost always are.

### Mongoose (`mongoose`) Support ###

```typescript
export module Context {
    const state: { connection: null | any } = { connection: null };

    export const Handler = async function () {
        /*** mongodb://localhost:27017 */
        const uri = process.env[ "DOCUMENTDB_URI" ] as string;

        if ( state.connection == null ) {
            state.connection = Mongoose.connect( uri, {
                /***
                 * Defaults to "test"; Personally, I also capitalize
                 * database name(s) and always keep them singular.
                 *
                 * The reasoning behing, say we're attempting to perform
                 * an action, programatically (psuedo-code):
                 *
                 * @example
                 * FILTER Authorization.username WHERE username === "Segmentational";
                 *
                 * Overall, it makes programattic usage seemingly more object-oriented
                 */
                dbName: "Authorization",
                /*** Required */
                replicaSet: "rs0",
                /*** Required */
                directConnection: true,
                /*** Required (Redacted) */
                user: process.env[ "DOCUMENTDB_USERNAME" ],
                /*** Required (Redacted) */
                pass: process.env[ "DOCUMENTDB_PASSWORD" ],
                /*** Optional (But Helps Time Spent Debugging) */
                serverSelectionTimeoutMS: 5000,
                /*** Required */
                retryWrites: false,
                /*** Required */
                tlsAllowInvalidHostnames: true,
                tlsAllowInvalidCertificates: true,
                /*** Required */
                tls: true,
                /*** Required */
                tlsCAFile: Path.join( __dirname, "us-east-2-bundle.pem" )
            } ).then( () => Mongoose );

            // `await`ing connection after assigning to the `conn` variable
            // to avoid multiple function calls, which creates new connections
            void await state.connection;
        }

        return state.connection;
    };

    void ( async () => Handler() );
}
```

### `mongodb` Usage ###

Note, the following is more difficult to achieve (in comparison to mongoose with the passive keepalive).

However, I've managed to get the following working with a personally hosted DocumentDB instance,
and via a localhost connection tunneled through a bastion.

```typescript
/// See mongoose example for better inline annotations regarding
/// connection configuration
export const Connection = async function (): Promise<void> {
    if ( !( Connection.lock ) ) {
        const validator = new RegExp( "^(mongodb:(?:\\/{2})?)((\\w+?):(\\w+?)@|:?@?)(\\S+?):(\\d+)(\\/(\\S+?))?(\\?replicaSet=(\\S+?))?$", "gm" );

        const options: import("mongodb").MongoClientOptions = {
            auth: {
                username: "...",
                password: "..."
            },
            connectTimeoutMS: 5000,
            directConnection: true,
            replicaSet: "rs0",
            appName: "Nexus-API",
            authMechanism: "DEFAULT",
            tlsCAFile: Path.join( __dirname, "us-east-2-bundle.pem" ),
            tls: true,
            tlsAllowInvalidHostnames: true,
            tlsAllowInvalidCertificates: true,
            retryWrites: false
        } as const;

        Connection.options = options;

        // validator.test( (URI) ? URI : "" ) || ( () => {
        //     console.log( "Error - Invalid URI" );
        //     process.exit( 1 );
        // } )();
    }

    async function Handler(): Promise<import("mongodb").MongoClient | undefined> {
        return new Promise( async (resolve) => {
            const Client = await import("mongodb").then( (Module) => Module.MongoClient );

            /*** mongodb://localhost:27017 */
            Client.connect( process.env[ "MONGO_URI" ]!, Connection.options!, (exception, connection) => {
                if ( exception ) throw exception;

                Connection.client = connection;

                resolve( connection );
            } );
        } );
    }

    void await Handler();

    ( Connection?.client?.readyState !== 1 ) && Reflect.set( Connection, "lock", false );

    return ( Connection?.lock ) ? Connection?.client : Handler();
};

Connection.lock = false;

Connection.data = Object.create( {} );
Connection.options = Object.create( {} );
Connection.client = Object.create( {} );
```

## Local Proxy HTTP Response Testing ##

**HTTP Response Times** (*via `express` application*)

```
[Timestamp] [Debug] 'HTTP Response Duration: 0.008 Second(s)'
```

## JSON Schema + IDE Extensions ##

https://www.jetbrains.com/help/idea/json.html

```shell
const STATUS_CODES = {
  100: 'Continue',                   // RFC 7231 6.2.1
  101: 'Switching Protocols',        // RFC 7231 6.2.2
  102: 'Processing',                 // RFC 2518 10.1 (obsoleted by RFC 4918)
  103: 'Early Hints',                // RFC 8297 2
  200: 'OK',                         // RFC 7231 6.3.1
  201: 'Created',                    // RFC 7231 6.3.2
  202: 'Accepted',                   // RFC 7231 6.3.3
  203: 'Non-Authoritative Information', // RFC 7231 6.3.4
  204: 'No Content',                 // RFC 7231 6.3.5
  205: 'Reset Content',              // RFC 7231 6.3.6
  206: 'Partial Content',            // RFC 7233 4.1
  207: 'Multi-Status',               // RFC 4918 11.1
  208: 'Already Reported',           // RFC 5842 7.1
  226: 'IM Used',                    // RFC 3229 10.4.1
  300: 'Multiple Choices',           // RFC 7231 6.4.1
  301: 'Moved Permanently',          // RFC 7231 6.4.2
  302: 'Found',                      // RFC 7231 6.4.3
  303: 'See Other',                  // RFC 7231 6.4.4
  304: 'Not Modified',               // RFC 7232 4.1
  305: 'Use Proxy',                  // RFC 7231 6.4.5
  307: 'Temporary Redirect',         // RFC 7231 6.4.7
  308: 'Permanent Redirect',         // RFC 7238 3
  400: 'Bad Request',                // RFC 7231 6.5.1
  401: 'Unauthorized',               // RFC 7235 3.1
  402: 'Payment Required',           // RFC 7231 6.5.2
  403: 'Forbidden',                  // RFC 7231 6.5.3
  404: 'Not Found',                  // RFC 7231 6.5.4
  405: 'Method Not Allowed',         // RFC 7231 6.5.5
  406: 'Not Acceptable',             // RFC 7231 6.5.6
  407: 'Proxy Authentication Required', // RFC 7235 3.2
  408: 'Request Timeout',            // RFC 7231 6.5.7
  409: 'Conflict',                   // RFC 7231 6.5.8
  410: 'Gone',                       // RFC 7231 6.5.9
  411: 'Length Required',            // RFC 7231 6.5.10
  412: 'Precondition Failed',        // RFC 7232 4.2
  413: 'Payload Too Large',          // RFC 7231 6.5.11
  414: 'URI Too Long',               // RFC 7231 6.5.12
  415: 'Unsupported Media Type',     // RFC 7231 6.5.13
  416: 'Range Not Satisfiable',      // RFC 7233 4.4
  417: 'Expectation Failed',         // RFC 7231 6.5.14
  418: 'I\'m a Teapot',              // RFC 7168 2.3.3
  421: 'Misdirected Request',        // RFC 7540 9.1.2
  422: 'Unprocessable Entity',       // RFC 4918 11.2
  423: 'Locked',                     // RFC 4918 11.3
  424: 'Failed Dependency',          // RFC 4918 11.4
  425: 'Too Early',                  // RFC 8470 5.2
  426: 'Upgrade Required',           // RFC 2817 and RFC 7231 6.5.15
  428: 'Precondition Required',      // RFC 6585 3
  429: 'Too Many Requests',          // RFC 6585 4
  431: 'Request Header Fields Too Large', // RFC 6585 5
  451: 'Unavailable For Legal Reasons', // RFC 7725 3
  500: 'Internal Server Error',      // RFC 7231 6.6.1
  501: 'Not Implemented',            // RFC 7231 6.6.2
  502: 'Bad Gateway',                // RFC 7231 6.6.3
  503: 'Service Unavailable',        // RFC 7231 6.6.4
  504: 'Gateway Timeout',            // RFC 7231 6.6.5
  505: 'HTTP Version Not Supported', // RFC 7231 6.6.6
  506: 'Variant Also Negotiates',    // RFC 2295 8.1
  507: 'Insufficient Storage',       // RFC 4918 11.5
  508: 'Loop Detected',              // RFC 5842 7.2
  509: 'Bandwidth Limit Exceeded',
  510: 'Not Extended',               // RFC 2774 7
  511: 'Network Authentication Required' // RFC 6585 6
};
```
