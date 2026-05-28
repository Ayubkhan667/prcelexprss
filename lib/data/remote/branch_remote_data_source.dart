import 'package:dio/dio.dart';

import '../models/branch_model.dart';
import 'api_client.dart';
import 'remote_payload_parser.dart';

abstract class BranchRemoteDataSource {
  Future<List<BranchModel>> fetchBranches();

  Future<BranchModel?> fetchBranchById(String id);

  Future<void> saveBranch({
    required BranchModel branch,
    required bool isEdit,
  });
}

class ApiBranchRemoteDataSource implements BranchRemoteDataSource {
  ApiBranchRemoteDataSource({required ApiClient apiClient})
      : client = apiClient.client;

  final Dio client;

  @override
  Future<List<BranchModel>> fetchBranches() async {
    final response = await client.get('/branches');
    return RemotePayloadParser.parseList(response.data)
        .map(BranchModel.fromMap)
        .toList();
  }

  @override
  Future<BranchModel?> fetchBranchById(String id) async {
    try {
      final response = await client.get('/branches/$id');
      final payload = RemotePayloadParser.parseOptionalMap(response.data);
      return payload == null ? null : BranchModel.fromMap(payload);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<void> saveBranch({
    required BranchModel branch,
    required bool isEdit,
  }) async {
    if (isEdit) {
      await client.put('/branches/${branch.id}', data: branch.toMap());
      return;
    }

    final payload = branch.toMap();
    if ((payload['id'] as String?)?.trim().isEmpty ?? false) {
      payload.remove('id');
    }

    await client.post('/branches', data: payload);
  }
}
