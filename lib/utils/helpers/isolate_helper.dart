import 'dart:convert';
import 'package:flutter/foundation.dart';


class IsolateHelper {
  /// Parse JSON in isolate to avoid blocking UI
  static Future<T> parseJsonInIsolate<T>(
    String jsonString,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    return await compute(_parseJson<T>, _JsonParseParams(jsonString, fromJson));
  }

  /// Parse JSON list in isolate
  static Future<List<T>> parseJsonListInIsolate<T>(
    String jsonString,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    return await compute(_parseJsonList<T>, _JsonParseParams(jsonString, fromJson));
  }

  /// Process large dataset in isolate
  static Future<List<R>> processListInIsolate<T, R>(
    List<T> data,
    R Function(T) processor,
  ) async {
    return await compute(_processList<T, R>, _ListProcessParams(data, processor));
  }

  /// Filter large list in isolate
  static Future<List<T>> filterListInIsolate<T>(
    List<T> data,
    bool Function(T) predicate,
  ) async {
    return await compute(_filterList<T>, _FilterParams(data, predicate));
  }

  /// Sort large list in isolate
  static Future<List<T>> sortListInIsolate<T>(
    List<T> data,
    int Function(T, T) compare,
  ) async {
    return await compute(_sortList<T>, _SortParams(data, compare));
  }

  /// Search in large dataset in isolate
  static Future<List<T>> searchInIsolate<T>(
    List<T> data,
    bool Function(T, String) matcher,
    String query,
  ) async {
    return await compute(_search<T>, _SearchParams(data, matcher, query));
  }

  // Private isolate functions

  static T _parseJson<T>(_JsonParseParams<T> params) {
    final Map<String, dynamic> json = jsonDecode(params.jsonString);
    return params.fromJson(json);
  }

  static List<T> _parseJsonList<T>(_JsonParseParams<T> params) {
    final List<dynamic> jsonList = jsonDecode(params.jsonString);
    return jsonList.map((json) => params.fromJson(json as Map<String, dynamic>)).toList();
  }

  static List<R> _processList<T, R>(_ListProcessParams<T, R> params) {
    return params.data.map(params.processor).toList();
  }

  static List<T> _filterList<T>(_FilterParams<T> params) {
    return params.data.where(params.predicate).toList();
  }

  static List<T> _sortList<T>(_SortParams<T> params) {
    final List<T> sorted = List.from(params.data);
    sorted.sort(params.compare);
    return sorted;
  }

  static List<T> _search<T>(_SearchParams<T> params) {
    return params.data.where((item) => params.matcher(item, params.query)).toList();
  }
}

// Parameter classes for isolate functions

class _JsonParseParams<T> {
  final String jsonString;
  final T Function(Map<String, dynamic>) fromJson;

  _JsonParseParams(this.jsonString, this.fromJson);
}

class _ListProcessParams<T, R> {
  final List<T> data;
  final R Function(T) processor;

  _ListProcessParams(this.data, this.processor);
}

class _FilterParams<T> {
  final List<T> data;
  final bool Function(T) predicate;

  _FilterParams(this.data, this.predicate);
}

class _SortParams<T> {
  final List<T> data;
  final int Function(T, T) compare;

  _SortParams(this.data, this.compare);
}

class _SearchParams<T> {
  final List<T> data;
  final bool Function(T, String) matcher;
  final String query;

  _SearchParams(this.data, this.matcher, this.query);
}

