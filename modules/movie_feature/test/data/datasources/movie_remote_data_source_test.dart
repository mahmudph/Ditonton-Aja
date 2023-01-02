import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:movie_feature/data/models/movie_detail_model.dart';
import 'package:movie_feature/data/models/movie_response.dart';
import 'package:movie_feature/movie_feature.dart';

import '../../json_reader.dart';
import '../../mocks/mocks.dart';

void main() {
  late MovieRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  const baseUrl = 'test.localhost';
  const tId = 1;

  setUp(
    () {
      mockHttpClient = MockHttpClient();
      dataSource = MovieRemoteDataSourceImpl(
        client: mockHttpClient,
        baseUrl: baseUrl,
      );
    },
  );

  group(
    'get Now Playing Movies',
    () {
      final tMovieList = MovieResponse.fromJson(
              json.decode(readJson('dummy_data/now_playing.json')))
          .movieList;

      test('should return list of Movie Model when the response code is 200',
          () async {
        // arrange
        when(
          () => mockHttpClient.get(
            Uri.parse('$baseUrl/movie/now_playing'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            readJson('dummy_data/now_playing.json'),
            200,
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
            },
          ),
        );

        // act
        final result = await dataSource.getNowPlayingMovies();
        // assert
        expect(result, equals(tMovieList));
      });

      test(
        'should throw a Exception when the response code is 404 or other',
        () async {
          // arrange
          when(
            () => mockHttpClient.get(
              Uri.parse('$baseUrl/movie/now_playing'),
            ),
          ).thenAnswer(
            (_) async => http.Response('Not Found', 404),
          );

          // act
          final call = dataSource.getNowPlayingMovies();
          // assert
          expect(() => call, throwsA(isA<Exception>()));
        },
      );
    },
  );

  group(
    'get Popular Movies',
    () {
      final tMovieList = MovieResponse.fromJson(
              json.decode(readJson('dummy_data/popular.json')))
          .movieList;

      test(
        'should return list of movies when response is success (200)',
        () async {
          // arrange
          when(
            () => mockHttpClient.get(
              Uri.parse('$baseUrl/movie/popular'),
            ),
          ).thenAnswer(
            (_) async => http.Response(
              readJson('dummy_data/popular.json'),
              200,
              headers: {
                HttpHeaders.contentTypeHeader:
                    'application/json; charset=utf-8',
              },
            ),
          );
          // act
          final result = await dataSource.getPopularMovies();
          // assert
          expect(result, tMovieList);
        },
      );

      test(
        'should throw a Exception when the response code is 404 or other',
        () async {
          // arrange
          when(() => mockHttpClient.get(Uri.parse('$baseUrl/movie/popular')))
              .thenAnswer(
            (_) async => http.Response('Not Found', 404),
          );
          // act
          final call = dataSource.getPopularMovies();
          // assert
          expect(() => call, throwsA(isA<Exception>()));
        },
      );
    },
  );

  group(
    'get Top Rated Movies',
    () {
      final tMovieList = MovieResponse.fromJson(
        json.decode(
          readJson('dummy_data/top_rated.json'),
        ),
      ).movieList;

      test(
        'should return list of movies when response code is 200 ',
        () async {
          // arrange
          when(
            () => mockHttpClient.get(
              Uri.parse('$baseUrl/movie/top_rated'),
            ),
          ).thenAnswer(
            (_) async => http.Response(
              readJson('dummy_data/top_rated.json'),
              200,
              headers: {
                HttpHeaders.contentTypeHeader:
                    'application/json; charset=utf-8',
              },
            ),
          );
          // act
          final result = await dataSource.getTopRatedMovies();
          // assert
          expect(result, tMovieList);
        },
      );

      test(
        'should throw Exception when response code is other than 200',
        () async {
          // arrange
          when(
            () => mockHttpClient.get(
              Uri.parse('$baseUrl/movie/top_rated'),
            ),
          ).thenAnswer(
            (_) async => http.Response('Not Found', 404),
          );
          // act
          final call = dataSource.getTopRatedMovies();
          // assert
          expect(() => call, throwsA(isA<Exception>()));
        },
      );
    },
  );

  group(
    'get movie detail',
    () {
      final tMovieDetail = MovieDetailResponse.fromJson(
        json.decode(
          readJson('dummy_data/movie_detail.json'),
        ),
      );

      test(
        'should return movie detail when the response code is 200',
        () async {
          // arrange
          when(
            () => mockHttpClient.get(
              Uri.parse('$baseUrl/movie/$tId'),
            ),
          ).thenAnswer(
            (_) async => http.Response(
              readJson('dummy_data/movie_detail.json'),
              200,
              headers: {
                HttpHeaders.contentTypeHeader:
                    'application/json; charset=utf-8',
              },
            ),
          );
          // act
          final result = await dataSource.getMovieDetail(tId);
          // assert
          expect(result, equals(tMovieDetail));
        },
      );

      test(
        'should throw Server Exception when the response code is 404 or other',
        () async {
          // arrange
          when(() => mockHttpClient.get(Uri.parse('$baseUrl/movie/$tId')))
              .thenAnswer(
            (_) async => http.Response('Not Found', 404),
          );
          // act
          final call = dataSource.getMovieDetail(tId);
          // assert
          expect(() => call, throwsA(isA<Exception>()));
        },
      );
    },
  );

  group('get movie recommendations', () {
    final tMovieList = MovieResponse.fromJson(
      json.decode(
        readJson('dummy_data/movie_recommendations.json'),
      ),
    ).movieList;
    test(
      'should return list of Movie Model when the response code is 200',
      () async {
        // arrange
        when(
          () => mockHttpClient.get(
            Uri.parse('$baseUrl/movie/$tId/recommendations'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            readJson('dummy_data/movie_recommendations.json'),
            200,
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
            },
          ),
        );
        // act
        final result = await dataSource.getMovieRecommendations(tId);
        // assert
        expect(result, equals(tMovieList));
      },
    );

    test('should throw Server Exception when the response code is 404 or other',
        () async {
      // arrange
      when(
        () => mockHttpClient.get(
          Uri.parse('$baseUrl/movie/$tId/recommendations'),
        ),
      ).thenAnswer(
        (_) async => http.Response('Not Found', 404),
      );
      // act
      final call = dataSource.getMovieRecommendations(tId);
      // assert
      expect(() => call, throwsA(isA<Exception>()));
    });
  });

  group(
    'search movies',
    () {
      final tSearchResult = MovieResponse.fromJson(
        json.decode(
          readJson('dummy_data/search_spiderman_movie.json'),
        ),
      ).movieList;

      const tQuery = 'Spiderman';

      test(
        'should return list of movies when response code is 200',
        () async {
          // arrange
          when(
            () => mockHttpClient.get(
              Uri.parse('$baseUrl/search/movie?query=$tQuery'),
            ),
          ).thenAnswer(
            (_) async => http.Response(
              readJson('dummy_data/search_spiderman_movie.json'),
              200,
              headers: {
                HttpHeaders.contentTypeHeader:
                    'application/json; charset=utf-8',
              },
            ),
          );
          // act
          final result = await dataSource.searchMovies(tQuery);
          // assert
          expect(result, tSearchResult);
        },
      );

      test(
        'should throw Exception when response code is other than 200',
        () async {
          // arrange
          when(
            () => mockHttpClient.get(
              Uri.parse('$baseUrl/search/movie?query=$tQuery'),
            ),
          ).thenAnswer(
            (_) async => http.Response('Not Found', 404),
          );

          // act
          final call = dataSource.searchMovies(tQuery);
          // assert
          expect(call, throwsA(isA<Exception>()));
        },
      );
    },
  );
}
