part of 'flutter_effect_queue_manager.dart';


abstract class EffectQueueProtocol {
  onEffectBeganNotify(Map notify);
  onEffectEndNotify(Map notify){
    print(notify);
  }
}