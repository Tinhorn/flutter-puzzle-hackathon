import 'package:dio/dio.dart';
import 'package:flutter_puzzle_hack/auth/secrets.dart';
import 'package:json_annotation/json_annotation.dart';

part 'giphy.g.dart';

class GiphyApi {
  Future<GiphyGifResponse?> random({
    required String tag,
  }) async {
    Dio dio = Dio(BaseOptions(
      baseUrl: 'https://api.giphy.com/v1/gifs/random',
      queryParameters: {"rating": "g"},
    ));

    Response userData = await dio.get('', queryParameters: {
      "api_key": giphyKey,
      "tag": tag,
    });

    var data = userData.data['data'];
    if (data is List) {
      return null;
    }
    return GiphyGifResponse.fromJson(data);
  }
}

@JsonSerializable(
  explicitToJson: true,
)
class GiphyApiResponse {
  final List<GiphyGifResponse> data;

  GiphyApiResponse({required this.data});

  factory GiphyApiResponse.fromJson(Map<String, dynamic> json) =>
      _$GiphyApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GiphyApiResponseToJson(this);
}

@JsonSerializable(
  explicitToJson: true,
)
class GiphyGifResponse {
  //Base url + [slug] = image
  final String slug;

  //Name of gif
  final String title;

  @JsonKey(
    name: "images",
    fromJson: fromImagesJsonToOriginalUrl,
    toJson: fromImagesJsonToDownSizedUrl,
  )
  final GiphyImageUrl imageUrl;

  final String bitly_url;

  GiphyGifResponse(
    this.slug,
    this.title,
    this.imageUrl,
    this.bitly_url,
  );

  factory GiphyGifResponse.fromJson(Map<String, dynamic> json) =>
      _$GiphyGifResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GiphyGifResponseToJson(this);
}

GiphyImageUrl fromImagesJsonToOriginalUrl(Map<String, dynamic> json) {
  return GiphyImageUrl(json["preview_gif"]["url"], json["downsized"]["url"]);
}

String fromImagesJsonToDownSizedUrl(GiphyImageUrl imageUrl) {
  return imageUrl.previewUrl;
}

class GiphyImageUrl {
  final String previewUrl;
  final String originalUrl;

  GiphyImageUrl(this.previewUrl, this.originalUrl);
}
