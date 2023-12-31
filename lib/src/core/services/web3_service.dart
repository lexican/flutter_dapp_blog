import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class Web3Service {
  final _apiUrl =
      "https://sepolia.infura.io/v3/${dotenv.get('INFURA_API_KEY')}";

  final String _wsUrl =
      "ws://sepolia.infura.io/v3/${dotenv.get('INFURA_API_KEY')}";

  final _contractAddress = dotenv.get('CONTRACT_ADDRESS');

  final _privateKey = dotenv.get('PRIVATE_KEY');
  final _contractName = "Blog";

  final _httpClient = Client();

  // ignore: prefer_typing_uninitialized_variables
  late Web3Client _ethClient;

  init() async {
    _ethClient = Web3Client(
      _apiUrl,
      _httpClient,
      socketConnector: () {
        return IOWebSocketChannel.connect(_wsUrl).cast<String>();
      },
    );
  }

  Future<String> readAbiJson() async {
    String abiStringFile = await rootBundle.loadString("assets/json/abi.json");
    var jsonAbi = jsonDecode(abiStringFile);
    return jsonEncode(jsonAbi['abi']);
  }

  Future<EthPrivateKey> getCredentials() async {
    return EthPrivateKey.fromHex(_privateKey);
  }

  Future<EthereumAddress> getAddress() async {
    Credentials credentials = await getCredentials();
    return credentials.address;
  }

  Future<DeployedContract> _getContract() async {
    String jsonContent = await readAbiJson();
    final contract = DeployedContract(
      ContractAbi.fromJson(
        jsonContent,
        _contractName,
      ),
      EthereumAddress.fromHex(_contractAddress),
    );
    return contract;
  }

  Future<List> getPosts() async {
    DeployedContract contract = await _getContract();

    try {
      List<dynamic> posts = await _ethClient.call(
        contract: contract,
        function: contract.function("getPosts"),
        params: [],
      );

      return posts;
    } catch (error, _) {
      // print("error $error");
      // print("trace $trace");
    }

    return [];
  }

  Future<bool> createPost({
    required String title,
    required String description,
    required String imageUrl,
  }) async {
    Credentials key = await getCredentials();

    int networkId = await _ethClient.getNetworkId();

    final contract = await _getContract();

    await _ethClient.sendTransaction(
      key,
      Transaction.callContract(
        contract: contract,
        function: contract.function("createPost"),
        parameters: [
          title,
          description,
          imageUrl,
        ],
      ),
      chainId: networkId,
    );
    return true;
  }

  Future<bool> updatePost({
    required String title,
    required String description,
    required String imageUrl,
    required BigInt uid,
  }) async {
    Credentials key = await getCredentials();

    int networkId = await _ethClient.getNetworkId();

    final contract = await _getContract();

    await _ethClient.sendTransaction(
      key,
      Transaction.callContract(
        contract: contract,
        function: contract.function("updatePost"),
        parameters: [
          title,
          description,
          imageUrl,
          uid,
        ],
      ),
      chainId: networkId,
    );
    return true;
  }

  Future<bool> deletePost({
    required BigInt uid,
  }) async {
    Credentials key = await getCredentials();

    int networkId = await _ethClient.getNetworkId();

    final contract = await _getContract();

    await _ethClient.sendTransaction(
      key,
      Transaction.callContract(
        contract: contract,
        function: contract.function("deletePost"),
        parameters: [
          uid,
        ],
      ),
      chainId: networkId,
    );
    return true;
  }
}
