# Dartez

[![Star on GitHub](https://img.shields.io/github/stars/Tezsure/Dartez?style=flat&logo=github&colorB=green&label=stars)](https://github.com/Tezsure/Dartez)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![Github issues](https://img.shields.io/github/issues/Tezsure/Dartez)](https://github.com/Tezsure/Dartez/issues?q=is%3Aissue+is%3Aopen+)

<!-- [![Tezster banner](https://tezster.s3-ap-southeast-1.amazonaws.com/TEZSTER_CLI/1_jDB5enULQVo2UfeiwD32qA.png)](https://github.com/Tezsure) -->
A library for building decentralized applications in Flutter, currently focused on the Tezos platform. Dartez package contains all the function that is required to build tezos application.




## What Is Tezos

Tezos is a decentralized blockchain that governs itself by establishing a true digital commonwealth. It facilitates formal verification, a technique which mathematically proves the correctness of the code governing transactions and boosts the security of the most sensitive or financially weighted smart contracts.

## Getting Started

Check out the [example](https://github.com/Tezsure/Dartez/tree/master/example) directory for a sample app for using Dartez.


## OS Support
* Android
* iOS
* Web


## Web Setup

Download the [sodium.js](https://raw.githubusercontent.com/jedisct1/libsodium.js/master/dist/browsers-sumo/sodium.js) file and add it to your flutter web directory. Include `sodium.js` in your web/index.html.

``` html
<script src="sodium.js"></script>
```


<em>No additional steps required for Android and iOS.</em>


## Import It
Now in your Dart code, you can use:

``` dart
import 'package:dartez/dartez.dart';
```



## Features

<!-- * Tezos wallet utilities. -->
  * [Get Balance](#get-balance)
  * [Generate Mnemonics](#generate-mnemonics)
  * [Generate Keys From Mnemonic](#generate-keys-from-mnemonic)
  * [Generate Keys From Mnemonics And Passphrase](#generate-keys-from-mnemonics-and-passphrase)
  * [Reveal An Account](#reveal-an-account)
  * [Unlock Fundraiser Identity](#unlock-fundraiser-identity)
  * [Restore Identity From Derivation Path](#restore-identity-from-derivation-path)
  * [Get Keys From Secret Key](#get-keys-from-secret-key)
  * [Delegate An Account](#delegate-an-account)
  * [Transfer Balance](#transfer-balance)
  * [Deploy A Contract](#deploy-a-contract)
  * [Call A Contract](#call-a-contract)
  * [Operation Confirmation](#operation-confirmation)
  * [Pre Apply Contract Invocation Operation](#pre-apply-contract-invocation-operation)
  * [Inject Operation](#inject-operation)
  * [Get Operation Status](#get-operation-status)
  * [Sign Payload](#sign-payload)
  * [Normalize Primitive Record Order](#normlaize-primitive-record-order)
  * [Get Block](#get-block)
  * [Write Address](#write-address)
  * [Get Contract Storage](#get-contract-storage)
  

## Usage
#### [Get Balance](#get-balance)

This function returns you the balance of your wallet on a particular network.

``` dart
String balance = await Dartez.getBalance('tz1c....ozGGs', 'your rpc server');
```


#### [Generate Mnemonics](#generate-mnemonics)
`generateMnemonic()` function returns a new set of mnemonic as a space separated words.
``` dart
String mnemonic = Dartez.generateMnemonic(); 
// mnemonic = sustain laugh capital ..... hundred same brave
```

#### [Generate Keys From Mnemonic](#generate-keys-from-mnemonic)
Generates a pair of keys using mnemonic.

``` dart
List<String> keys = await Dartez.getKeysFromMnemonic(mnemonic: "Your Mnemonic");

/* keys = [edsk.....vdC, edpk.....rQL, tz1.....28q] */
```

#### [Generate Keys From Mnemonics And Passphrase](#generate-keys-from-mnemonics-and-passphrase)
Generates a pair of keys using mnemonic & passphrase.

``` dart
List<String> identityWithMnemonic = await Dartez.getKeysFromMnemonicAndPassphrase(
      mnemonic: "your mnemonic",
      passphrase: "pa$\$w0rd",);

/* identityWithMnemonic = [edsk.....4w7, edpk.....zbx, tz1.....FZS] */
```

#### [Reveal An Account](#reveal-an-account)
This function reveal an account's publicKey.

``` dart
var server = '';

var keyStore = KeyStoreModel(
      publicKeyHash: 'tz1U.....W5MHgi',
      secretKey: 'edskRp......bL2B6g',
      publicKey: 'edpktt.....U1gYJu2',
    );

var signer = await Dartez.createSigner(
        Dartez.writeKeyWithHint(keyStore.secretKey, 'edsk'));

var result =
        await Dartez.sendKeyRevealOperation(server, signer, keyStore);

print('${result['operationGroupID']}');
```


#### [Unlock Fundraiser Identity](#unlock-fundraiser-identity)
Generates a pair of keys using mnemonic, email & passphrase.

``` dart
List<String> identityFundraiser = await Dartez.unlockFundraiserIdentity(
    mnemonic: "your mnemonic",
    email: "test@example.com",
    passphrase: "5tj...imq");

/* identityFundraiser = [edsk.....GVb, edpk.....dw2, tz1.....6Pv] */
```



#### [Restore Identity From Derivation Path](#restore-identity-from-derivation-path)
Returns a pair of keys using a derivation path and mnemonic.

``` dart
var derivationPath = 'your derivation path';
var mnemonic = 'your mnemonic';

List<String> keyStore = await Dartez.restoreIdentityFromDerivationPath(derivationPath, mnemonic);

/* keyStore = [edsk.....GVb, edpk.....dw2, tz1.....6Pv] */
```



#### [Get Keys From Secret Key](#get-keys-from-secret-key)
Returns a pair of keys using secret key.

``` dart
List<String> keys = Dartez.getKeysFromSecretKey("edsk.....vdC");

/* keys = [edsk.....vdC, edpk.....rQL, tz1....28q] */
```



#### [Delegate An Account](#delegate-an-account)
This functions delegates the account to the baker account address.

``` dart
var server = '';

var keyStore = KeyStoreModel(
      publicKey: 'edpk.....rrj',
      secretKey: 'edsk.....yHH',
      publicKeyHash: 'tz1.....hxy',
    );

var signer = await Dartez.createSigner(
        Dartez.writeKeyWithHint(keyStore.secretKey, 'edsk'));

var result = await Dartez.sendDelegationOperation(
      server,
      signer,
      keyStore,
      'tz1.....Lnc',
      10000,
    );

print("Applied operation ===> $result['appliedOp']");
print("Operation groupID ===> $result['operationGroupID']");

```


#### [Transfer Balance](#transfer-balance)
A configured signer is required for the transfer operation. This function helps you transfer xtz from one wallet to another.

``` dart
var server = '';

var keyStore = KeyStoreModel(
      publicKey: 'edpk.....rrj',
      secretKey: 'edsk.....yHH',
      publicKeyHash: 'tz1.....hxy',
    );

var signer = await Dartez.createSigner(
    Dartez.writeKeyWithHint(keyStore.secretKey, 'edsk'));
    
var result = await Dartez.sendTransactionOperation(
      server,
      signer,
      keyStore,
      'tz1.....Lnc',
      500000,
      1500,
    );

print("Applied operation ===> $result['appliedOp']");
print("Operation groupID ===> $result['operationGroupID']");

```


#### [Deploy A Contract](#deploy-a-contract)
Using contract deployment a user can directly write smart contracts in Michelson language and deploy it on Tezos chain using the `sendContractOriginationOperation()` method in return you'll get an origination id of the deployed contract that can be use to track the contract on chain.

``` dart
var server = '';

var contract = """parameter string;
    storage string;
    code { DUP;
        DIP { CDR ; NIL string ; SWAP ; CONS } ;
        CAR ; CONS ;
        CONCAT;
        NIL operation; PAIR}""";

var storage = '"Sample"';

var keyStore = KeyStoreModel(
      publicKey: 'edpk.....rrj',
      secretKey: 'edsk.....yHH',
      publicKeyHash: 'tz1.....hxy',
    );

var signer = await Dartez.createSigner(
        Dartez.writeKeyWithHint(keyStore.secretKey, 'edsk'));

var result = await Dartez.sendContractOriginationOperation(
      server,
      signer,
      keyStore,
      0,
      '',
      100000,
      1000,
      100000,
      contract,
      storage,
      codeFormat: TezosParameterFormat.Michelson,
    );

print("Operation groupID ===> $result['operationGroupID']");

```


#### [Call A Contract](#call-a-contract)
To call or invoke a deployed contract just use the `sendContractInvocationOperation()` method in return you'll get an origination id of the invoked contract that can be used to track the contracts on chain.

``` dart
var server = '';

var keyStore = KeyStoreModel(
      publicKey: 'edpk.....rrj',
      secretKey: 'edsk.....yHH',
      publicKeyHash: 'tz1.....hxy',
    );

var signer = await Dartez.createSigner(
        Dartez.writeKeyWithHint(keyStore.secretKey, 'edsk'));

var contractAddress = ['KT1.....xMY'];

var resultInvoke = await Dartez.sendContractInvocationOperation(
        server,
        signer,
        keyStore,
        contractAddress,
        [10000],
        100000,
        1000,
        100000,
        [''],
        ["Cryptonomicon"],  
        codeFormat: TezosParameterFormat.Michelson);

print("Operation groupID ===> $resultInvoke['operationGroupID']");

```


#### [Operation Confirmation](#operation-confirmation)
To await for confirmation for any operation on chain, use `awaitOperationConfirmation()` method which confirms the operations.

``` dart
var server = '';

var network = 'ithacanet';

var serverInfo = {
      'url': '',
      'apiKey': '',
      'network': network
    };

var contract = """parameter string;
    storage string;
    code { DUP;
        DIP { CDR ; NIL string ; SWAP ; CONS } ;
        CAR ; CONS ;
        CONCAT;
        NIL operation; PAIR}""";

var storage = '"Sample"';

var keyStore = KeyStoreModel(
      publicKey: 'edpk.....rrj',
      secretKey: 'edsk.....yHH',
      publicKeyHash: 'tz1.....hxy',
    );

var signer = await Dartez.createSigner(
        Dartez.writeKeyWithHint(keyStore.secretKey, 'edsk'));

var result = await Dartez.sendContractOriginationOperation(
      server,
      signer,
      keyStore,
      0,
      '',
      100000,
      1000,
      100000,
      contract,
      storage,
      codeFormat: TezosParameterFormat.Michelson,
    );

print("Operation groupID ===> $result['operationGroupID']");

var groupId = result['operationGroupID'];

var conseilResult = await Dartez.awaitOperationConfirmation(
        serverInfo, network, groupId, 5);

print('Originated contract at ${conseilResult['originated_contracts']}');

```



#### [Pre Apply Contract Invocation Operation](#pre-apply-contract-invocation-operation)
Before injecting an operation to the blockchain, the operation needs to be validated to check for any errors. With the preapply RPC a simulation will be performed, and the effects of the operation(s) will be returned.
    
``` dart
var server = '';

var keyStore = KeyStoreModel(
      publicKeyHash: 'tz1U.....W5MHgi',
      secretKey: 'edskRp......bL2B6g',
      publicKey: 'edpktt.....U1gYJu2',
    );

var signer = await Dartez.createSigner(
        Dartez.writeKeyWithHint(keyStore.secretKey, 'edsk'));

var contract = ["KT1...fgH"];

var parameters = ["parameters"];


var opPair = Dartez.preapplyContractInvocationOperation(server, signer, keyStore, contract, [0], 120000, 1000, 100000, ['transfer'], parameters);
```



#### [Inject operation](#inject-operation)
`injectOperation()` injects the operation on to the blockchain. But before injecting the operation it’s a good idea to validate that it doesn’t contain any errors, using `preapplyContractInvocationOperation()`.

``` dart
var server = '';

var keyStore = KeyStoreModel(
      publicKeyHash: 'tz1U.....W5MHgi',
      secretKey: 'edskRp......bL2B6g',
      publicKey: 'edpktt.....U1gYJu2',
    );

var signer = await Dartez.createSigner(
        Dartez.writeKeyWithHint(keyStore.secretKey, 'edsk'));

var contract = ["KT1...fgH"];

var parameters = ["parameters"];

var opPair = Dartez.preapplyContractInvocationOperation(server, signer, keyStore, contract, [0], 120000, 1000, 100000, ['transfer'], parameters);

var opHash = await Dartez.injectOperation(server, opPair);
```



#### [Get Operation Status](#get-operation-status)
Get's the current status of an operation on the blockchain
``` dart
var server = '';
var opHash = '';

var status = await Dartez.getOperationStatus(server, opHash);
```


#### [Sign Payload](#sign-payload)
`signPayload()` signs a string of bytes. The wallets require a certain format for the bytes that need to be signed

``` dart

var signer = Dartez.createSigner(Dartez.writeKeyWithHint('secretKey', 'edsk'));

var payload = "03...";

String base58signature = Dartez.signPayload(signer: signer, payload: payload);
```

#### [Normalize Primitive Record Order](#normlaize-primitive-record-order)

``` dart
var data = 'MICHELINE_CODE';

var recordOrder = Dartez.normalizePrimitiveRecordOrder(data);
```



#### [Get Block](#get-block)
Return you the current block
``` dart
var server = '';

var block = await Dartez.getBlock(server);
```



#### [Write Address](#write-address)

``` dart
var address = 'tz1.....VLdc';

var writeAddress = Dartez.writeAddress(address);
```


#### [Get Contract Storage](#get-contract-storage)
It fetched the storage of the contract

``` dart
var server = '';

var accountHash = 'tz1.....VLdc';

var storage = await Dartez.getContractStorage(server, accountHash);
```




---
**NOTE:**
Use stable version of flutter to avoid package conflicts.

---



## Contributing

dartez is open source and we love to receive contributions from whosoever passionate with the technology.

There are many ways to contribute, from writing tutorials or blog posts, improving the documentation, bug reports and feature requests or writing code. We certainly welcome pull requests as well.

## Feature Requests And Bugs

Please file feature requests and bugs at the [issue tracker](https://github.com/Tezsure/Dartez/issues/new). If you want to contribute to this libary, please submit a Pull Request.<br>
You can get in touch with us for any open discussion and support via [Telegram](https://t.me/tezster).