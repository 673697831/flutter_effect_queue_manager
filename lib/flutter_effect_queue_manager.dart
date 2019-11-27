library flutter_effect_queue_manager;

import 'dart:ffi';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:svgaplayer_flutter/svgaplayer_flutter.dart';

part 'effect_queue_protocol.dart';
part 'effect_node.dart';

class FlutterEffectQueueManager {
  static final FlutterEffectQueueManager _instance = FlutterEffectQueueManager();
  static FlutterEffectQueueManager get singleton => _instance;
  Map<String, List<EffectNode>> globalQueue = {};

  clear(){
    globalQueue.clear();
  }

  clearTagQueue(String tag) {
    globalQueue[tag] = [];
  } 

  // SVGAAnimationController playSVGAOnQueue(String tag, String url) {
  //   List<EffectNode> queue = _getTagQueue(tag);
  //   queue.add(EffectNode()
  //     ..tag = tag
  //     ..duration = duration
  //     ..client = delegate
  //     ..userInfo = userInfo);
  //   if (queue.length == 1) {
  //     _playEffectWithTag(tag);
  //   }
  // }

  addAnimationOnTagQueue({String tag = "", double duration = 0, EffectQueueProtocol delegate, Map userInfo}) {
    List<EffectNode> queue = _getTagQueue(tag);
    queue.add(EffectNode()
      ..tag = tag
      ..duration = duration
      ..client = delegate
      ..userInfo = userInfo);
    if (queue.length == 1) {
      _playEffectWithTag(tag);
    }
  }

  endAnimateOnTagQueue({String tag, EffectQueueProtocol client}) {
    List<EffectNode> queue = _getTagQueue(tag);
    if (queue.length > 0) {
      EffectNode node = queue.first;
      if (node.duration == 0) {
        if (client == node.client) {
          queue.remove(node);
          _playEffectWithTag(tag);
        }
      }
    }
  }

  List<EffectNode> _getTagQueue(String tag) {
    if (globalQueue[tag] == null) {
      globalQueue[tag] = [];
    }
    return globalQueue[tag];
  }

  _playEffectWithTag(String tag) {
    List<EffectNode> queue = _getTagQueue(tag);
    if (queue.length > 0) {
      EffectNode node = queue.first;
      Map notify = {};
      notify["userInfo"] = node.userInfo;
      notify["tag"] = tag;
      node.client.onEffectBeganNotify(notify);
      if (node.duration > 0) {
        Future.delayed(Duration(milliseconds: (node.duration * 1000) as int), () {
          _delayEndEffect(tag);
        });
      }
    }
  }

  _delayEndEffect(String tag) {
    List<EffectNode> queue = _getTagQueue(tag);
    if (queue.length > 0) {
      queue.removeAt(0);
    }
    _playEffectWithTag(tag);
  }
}