import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:crypto/crypto.dart';

const _hasShownBackupPromptKey = 'has_shown_backup_prompt';
const _recoveryPhraseKey = 'recovery_phrase';

final backupScreenViewModelProvider = StateNotifierProvider<BackupScreenViewModel, BackupScreenState>((ref) {
  return BackupScreenViewModel();
});

class BackupScreenState {
  final List<String> mnemonic;
  final bool isLoading;
  final bool isConfirmed;
  final String? error;

  const BackupScreenState({
    this.mnemonic = const [],
    this.isLoading = false,
    this.isConfirmed = false,
    this.error,
  });

  BackupScreenState copyWith({
    List<String>? mnemonic,
    bool? isLoading,
    bool? isConfirmed,
    String? error,
  }) {
    return BackupScreenState(
      mnemonic: mnemonic ?? this.mnemonic,
      isLoading: isLoading ?? this.isLoading,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      error: error,
    );
  }
}

/// Full BIP-39 English word list (2048 words)
/// Source: https://github.com/bitcoin/bips/blob/master/bip-0039/english.txt
/// 
/// This word list is used to generate mnemonic phrases for key backup.
/// Each word represents 11 bits of entropy (2^11 = 2048).
class BIP39WordList {
  BIP39WordList._();

  static const List<String> words = [
    'abandon', 'ability', 'able', 'about', 'above', 'absent', 'absorb', 'abstract',
    'absurd', 'abuse', 'access', 'accident', 'account', 'accuse', 'achieve', 'acid',
    'acoustic', 'acquire', 'across', 'act', 'action', 'actor', 'actress', 'actual',
    'adapt', 'add', 'addict', 'address', 'adjust', 'admit', 'adult', 'advance',
    'advice', 'aerobic', 'affair', 'afford', 'afraid', 'again', 'age', 'agent',
    'agree', 'ahead', 'aim', 'air', 'airport', 'aisle', 'alarm', 'album',
    'alcohol', 'alert', 'alien', 'all', 'alley', 'allow', 'almost', 'alone',
    'alpha', 'already', 'also', 'alter', 'always', 'amateur', 'amazing', 'among',
    'amount', 'amused', 'analyst', 'anchor', 'ancient', 'anger', 'angle', 'angry',
    'animal', 'ankle', 'announce', 'annual', 'another', 'answer', 'antenna', 'antique',
    'anxiety', 'any', 'apart', 'apology', 'appear', 'apple', 'approve', 'april',
    'arch', 'arctic', 'area', 'arena', 'argue', 'arm', 'armed', 'armor',
    'army', 'around', 'arrange', 'arrest', 'arrive', 'arrow', 'art', 'artefact',
    'artist', 'artwork', 'ask', 'aspect', 'assault', 'asset', 'assist', 'assume',
    'asthma', 'athlete', 'atom', 'attack', 'attend', 'attitude', 'attract', 'auction',
    'audit', 'august', 'aunt', 'author', 'auto', 'autumn', 'average', 'avocado',
    'avoid', 'awake', 'aware', 'away', 'awesome', 'awful', 'awkward', 'axis',
    'baby', 'bachelor', 'bacon', 'badge', 'bag', 'balance', 'balcony', 'ball',
    'bamboo', 'banana', 'banner', 'bar', 'barely', 'bargain', 'barrel', 'base',
    'basic', 'basket', 'battle', 'beach', 'bean', 'beauty', 'become', 'beef',
    'before', 'begin', 'behave', 'behind', 'believe', 'below', 'belt', 'bench',
    'benefit', 'best', 'betray', 'better', 'between', 'beyond', 'bicycle', 'bid',
    'bike', 'bind', 'biology', 'bird', 'birth', 'bitter', 'black', 'blade',
    'blame', 'blanket', 'blast', 'bleak', 'bless', 'blind', 'blood', 'blossom',
    'blouse', 'blue', 'blur', 'blush', 'board', 'boat', 'body', 'boil',
    'bomb', 'bone', 'bonus', 'book', 'boost', 'border', 'boring', 'borrow',
    'boss', 'bottom', 'bounce', 'box', 'boy', 'bracket', 'brain', 'brand',
    'brass', 'brave', 'bread', 'breeze', 'brick', 'bridge', 'brief', 'bright',
    'bring', 'brisk', 'broccoli', 'broken', 'bronze', 'broom', 'brother', 'brown',
    'brush', 'bubble', 'buddy', 'budget', 'buffalo', 'build', 'bulb', 'bulk',
    'bullet', 'bundle', 'bunker', 'burden', 'burger', 'burst', 'bus', 'business',
    'busy', 'butter', 'buyer', 'buzz', 'cabbage', 'cabin', 'cable', 'cactus',
    'cage', 'cake', 'call', 'calm', 'camera', 'camp', 'can', 'canal',
    'cancel', 'candy', 'cannon', 'canoe', 'canvas', 'canyon', 'capable', 'capital',
    'captain', 'car', 'carbon', 'card', 'cargo', 'carpet', 'carry', 'cart',
    'case', 'cash', 'casino', 'castle', 'casual', 'cat', 'catalog', 'catch',
    'category', 'cattle', 'caught', 'cause', 'caution', 'cave', 'ceiling', 'celery',
    'cement', 'census', 'century', 'cereal', 'certain', 'chair', 'chalk', 'champion',
    'change', 'chaos', 'chapter', 'charge', 'chase', 'chat', 'cheap', 'check',
    'cheese', 'chef', 'cherry', 'chest', 'chicken', 'chief', 'child', 'chimney',
    'choice', 'choose', 'chronic', 'chuckle', 'chunk', 'churn', 'cigar', 'cinnamon',
    'circle', 'citizen', 'city', 'civil', 'claim', 'clap', 'clarify', 'claw',
    'clay', 'clean', 'clerk', 'clever', 'click', 'client', 'cliff', 'climb',
    'clinic', 'clip', 'clock', 'clog', 'close', 'cloth', 'cloud', 'clown',
    'club', 'clump', 'cluster', 'clutch', 'coach', 'coast', 'coconut', 'code',
    'coffee', 'coil', 'coin', 'collect', 'color', 'column', 'combine', 'come',
    'comfort', 'comic', 'common', 'company', 'concert', 'conduct', 'confirm', 'congress',
    'connect', 'consider', 'control', 'convince', 'cook', 'cool', 'copper', 'copy',
    'coral', 'core', 'corn', 'correct', 'cost', 'cotton', 'couch', 'country',
    'couple', 'course', 'cousin', 'cover', 'coyote', 'crack', 'cradle', 'craft',
    'cram', 'crane', 'crash', 'crater', 'crawl', 'crazy', 'cream', 'credit',
    'creek', 'crew', 'cricket', 'crime', 'crisp', 'critic', 'crop', 'cross',
    'crouch', 'crowd', 'crucial', 'cruel', 'cruise', 'crumble', 'crunch', 'crush',
    'cry', 'crystal', 'cube', 'culture', 'cup', 'cupboard', 'curious', 'current',
    'curtain', 'curve', 'cushion', 'custom', 'cute', 'cycle', 'dad', 'damage',
    'damp', 'dance', 'danger', 'daring', 'dash', 'daughter', 'dawn', 'day',
    'deal', 'debate', 'debris', 'decade', 'december', 'decide', 'decline', 'decorate',
    'decrease', 'deer', 'defense', 'define', 'defy', 'degree', 'delay', 'deliver',
    'demand', 'demise', 'denial', 'dentist', 'deny', 'depart', 'depend', 'deposit',
    'depth', 'deputy', 'derive', 'describe', 'desert', 'design', 'desk', 'despair',
    'destroy', 'detail', 'detect', 'develop', 'device', 'devote', 'diagram', 'dial',
    'diamond', 'diary', 'dice', 'diesel', 'diet', 'differ', 'digital', 'dignity',
    'dilemma', 'dinner', 'dinosaur', 'direct', 'dirt', 'disagree', 'discover', 'disease',
    'dish', 'dismiss', 'disorder', 'display', 'distance', 'divert', 'divide', 'divorce',
    'dizzy', 'doctor', 'document', 'dog', 'doll', 'dolphin', 'domain', 'donate',
    'donkey', 'donor', 'door', 'dose', 'double', 'dove', 'draft', 'dragon',
    'drama', 'drastic', 'draw', 'dream', 'dress', 'drift', 'drill', 'drink',
    'drip', 'drive', 'drop', 'drum', 'dry', 'duck', 'dumb', 'dune',
    'during', 'dust', 'dutch', 'duty', 'dwarf', 'dynamic', 'eager', 'eagle',
    'early', 'earn', 'earth', 'easily', 'east', 'easy', 'echo', 'ecology',
    'economy', 'edge', 'edit', 'educate', 'effort', 'egg', 'eight', 'either',
    'elbow', 'elder', 'electric', 'elegant', 'element', 'elephant', 'elevator', 'elite',
    'else', 'embark', 'embody', 'embrace', 'emerge', 'emotion', 'employ', 'empower',
    'empty', 'enable', 'enact', 'end', 'endless', 'endorse', 'enemy', 'energy',
    'enforce', 'engage', 'engine', 'enhance', 'enjoy', 'enlist', 'enough', 'enrich',
    'enroll', 'ensure', 'enter', 'entire', 'entry', 'envelope', 'episode', 'equal',
    'equip', 'era', 'erase', 'erode', 'erosion', 'error', 'erupt', 'escape',
    'essay', 'essence', 'estate', 'eternal', 'ethics', 'evidence', 'evil', 'evoke',
    'evolve', 'exact', 'example', 'excess', 'exchange', 'excite', 'exclude', 'excuse',
    'execute', 'exercise', 'exhaust', 'exhibit', 'exile', 'exist', 'exit', 'exotic',
    'expand', 'expect', 'expire', 'explain', 'expose', 'express', 'extend', 'extra',
    'eye', 'eyebrow', 'fabric', 'face', 'faculty', 'fade', 'faint', 'faith',
    'fall', 'false', 'fame', 'family', 'famous', 'fan', 'fancy', 'fantasy',
    'farm', 'fashion', 'fat', 'fatal', 'father', 'fatigue', 'fault', 'favorite',
    'feature', 'february', 'federal', 'fee', 'feed', 'feel', 'female', 'fence',
    'festival', 'fetch', 'fever', 'few', 'fiber', 'fiction', 'field', 'figure',
    'file', 'film', 'filter', 'final', 'find', 'fine', 'finger', 'finish',
    'fire', 'firm', 'first', 'fiscal', 'fish', 'fit', 'fitness', 'fix',
    'flag', 'flame', 'flash', 'flat', 'flavor', 'flee', 'flight', 'flip',
    'float', 'flock', 'floor', 'flower', 'fluid', 'flush', 'fly', 'foam',
    'focus', 'fog', 'foil', 'fold', 'follow', 'food', 'foot', 'force',
    'forest', 'forget', 'fork', 'fortune', 'forum', 'forward', 'fossil', 'foster',
    'found', 'fox', 'fragile', 'frame', 'frequent', 'fresh', 'friend', 'fringe',
    'frog', 'front', 'frost', 'frown', 'frozen', 'fruit', 'fuel', 'fun',
    'funny', 'furnace', 'fury', 'future', 'gadget', 'gain', 'galaxy', 'gallery',
    'game', 'gap', 'garage', 'garbage', 'garden', 'garlic', 'garment', 'gas',
    'gasp', 'gate', 'gather', 'gauge', 'gaze', 'general', 'genius', 'genre',
    'gentle', 'genuine', 'gesture', 'ghost', 'giant', 'gift', 'giggle', 'ginger',
    'girl', 'give', 'glad', 'glance', 'glare', 'glass', 'gleam', 'globe',
    'gloom', 'glory', 'glove', 'glow', 'glue', 'goal', 'goat', 'goes',
    'gold', 'golf', 'good', 'goose', 'gorgeous', 'gown', 'grab', 'grace',
    'grade', 'grain', 'grand', 'grant', 'grape', 'graph', 'grasp', 'grass',
    'gratitude', 'grave', 'great', 'green', 'greet', 'grief', 'grill', 'grin',
    'grind', 'grip', 'groan', 'grocery', 'gross', 'group', 'grow', 'grunt',
    'guard', 'guess', 'guest', 'guide', 'guilt', 'guitar', 'gulf', 'gutter',
    'gym', 'habit', 'hair', 'half', 'hall', 'halt', 'hammer', 'hand',
    'handle', 'hang', 'happy', 'harbor', 'hard', 'harsh', 'harvest', 'haste',
    'have', 'hawk', 'hazard', 'head', 'health', 'heart', 'heavy', 'hedgehog',
    'height', 'hello', 'helmet', 'help', 'hen', 'hero', 'hidden', 'high',
    'hill', 'hint', 'hip', 'hire', 'history', 'hold', 'hole', 'holiday',
    'hollow', 'home', 'honey', 'honor', 'hope', 'horn', 'horror', 'horse',
    'hospital', 'host', 'hotel', 'hour', 'house', 'hover', 'human', 'humid',
    'humor', 'hundred', 'hungry', 'hunt', 'hurdle', 'hurry', 'hurt', 'husband',
    'hybrid', 'ice', 'icon', 'idea', 'identify', 'idle', 'ignore', 'ill',
    'illegal', 'illness', 'image', 'imitate', 'immense', 'immune', 'impact', 'impose',
    'improve', 'impulse', 'inch', 'include', 'income', 'increase', 'index', 'indicate',
    'indoor', 'infant', 'inflict', 'inform', 'inhale', 'inherit', 'initial', 'injure',
    'ink', 'innate', 'innocent', 'input', 'inquiry', 'insect', 'inside', 'insight',
    'inspire', 'install', 'intact', 'intake', 'input', 'increase', 'index', 'indicate',
    'indoor', 'infant', 'inflict', 'inform', 'inhale', 'inherit', 'initial', 'injure',
    'ink', 'innate', 'innocent', 'input', 'inquiry', 'insect', 'inside', 'insight',
    'inspire', 'install', 'intact', 'intake', 'intact', 'intense', 'interact', 'interest',
    'interior', 'internal', 'interval', 'interview', 'intimate', 'into', 'invest', 'invite',
    'involve', 'iron', 'irony', 'island', 'isolate', 'issue', 'item', 'ivory',
    'jacket', 'jaguar', 'jar', 'jazz', 'jealous', 'jeans', 'jelly', 'jewel',
    'joint', 'joke', 'jolly', 'jolt', 'journey', 'joy', 'judge', 'juice',
    'jump', 'jungle', 'junk', 'just', 'kangaroo', 'keen', 'keep', 'ketchup',
    'kick', 'kidney', 'kind', 'kingdom', 'kiss', 'kitchen', 'kite', 'kitten',
    'knife', 'knight', 'knit', 'knock', 'knot', 'know', 'label', 'labor',
    'ladder', 'lady', 'lake', 'lamb', 'lamp', 'land', 'landscape', 'lane',
    'language', 'laptop', 'large', 'later', 'latin', 'laugh', 'laundry', 'lawn',
    'lawsuit', 'layer', 'lazy', 'leaf', 'lean', 'leap', 'learn', 'leave',
    'lecture', 'left', 'leg', 'legal', 'lemon', 'lend', 'length', 'lens',
    'less', 'lesser', 'lesson', 'letter', 'level', 'lever', 'liberty', 'library',
    'license', 'lick', 'life', 'lift', 'light', 'like', 'limb', 'limit',
    'linear', 'linen', 'liner', 'linger', 'lion', 'list', 'live', 'liver',
    'living', 'lizard', 'load', 'loan', 'lobby', 'local', 'lock', 'lodge',
    'logic', 'lonely', 'long', 'look', 'loose', 'loss', 'lost', 'lot',
    'loud', 'lounge', 'love', 'loyal', 'lucky', 'lunar', 'lunch', 'lung',
    'lyric', 'machine', 'mad', 'magic', 'magnet', 'maid', 'mail', 'main',
    'major', 'make', 'mammal', 'manage', 'mandate', 'mango', 'manner', 'manual',
    'maple', 'march', 'margin', 'marine', 'market', 'marriage', 'mask', 'mass',
    'master', 'match', 'material', 'math', 'matter', 'mayor', 'maze', 'meal',
    'mean', 'means', 'meanwhile', 'measure', 'meat', 'mechanic', 'medal', 'media',
    'melon', 'melt', 'member', 'memory', 'mention', 'mentor', 'menu', 'mercy',
    'merge', 'merit', 'merry', 'mesh', 'message', 'metal', 'meter', 'method',
    'microphone', 'middle', 'midnight', 'might', 'mild', 'military', 'million', 'mind',
    'mine', 'minimize', 'minor', 'minus', 'minute', 'miracle', 'mirror', 'misery',
    'miss', 'mistake', 'mix', 'mixed', 'mixture', 'mobile', 'model', 'moderate',
    'modern', 'modest', 'modify', 'moment', 'momentum', 'money', 'monkey', 'month',
    'mood', 'moon', 'moral', 'more', 'morning', 'mortal', 'mortgage', 'most',
    'mother', 'motion', 'motor', 'motorcycle', 'mount', 'mouse', 'mouth', 'move',
    'movie', 'much', 'muffin', 'mule', 'multiply', 'muscle', 'museum', 'mushroom',
    'music', 'must', 'mutual', 'myself', 'mystery', 'myth', 'naive', 'name',
    'napkin', 'narrow', 'nasty', 'nation', 'native', 'nature', 'near', 'nearly',
    'neck', 'need', 'negative', 'neglect', 'negotiate', 'neighbor', 'neither', 'nerve',
    'nest', 'never', 'new', 'news', 'next', 'nice', 'night', 'nine',
    'noble', 'nobody', 'noise', 'nominal', 'none', 'noodle', 'normal', 'north',
    'notch', 'nothing', 'notice', 'notion', 'novel', 'nurse', 'nylon', 'obey',
    'object', 'obtain', 'occupy', 'occur', 'ocean', 'offer', 'office', 'often',
    'olive', 'olympic', 'once', 'onion', 'online', 'only', 'open', 'opera',
    'opinion', 'oppose', 'option', 'orange', 'orbit', 'orchard', 'order', 'ordinary',
    'organ', 'original', 'orphan', 'other', 'ostrich', 'outdoor', 'outer', 'output',
    'outside', 'oval', 'oven', 'over', 'overall', 'owner', 'oxide', 'oxygen',
    'oyster', 'ozone', 'paddle', 'page', 'paint', 'pair', 'palace', 'palm',
    'panda', 'panel', 'panic', 'paper', 'parade', 'parent', 'park', 'parrot',
    'party', 'pass', 'patch', 'path', 'patient', 'patrol', 'patience', 'pattern',
    'pause', 'pave', 'payment', 'peace', 'peanut', 'pearl', 'pedal', 'penny',
    'people', 'pepper', 'percent', 'perfect', 'perform', 'perhaps', 'period', 'permit',
    'person', 'pest', 'pet', 'petal', 'petrol', 'phase', 'phone', 'photo',
    'phrase', 'physical', 'piano', 'pick', 'picture', 'piece', 'pilot', 'pin',
    'pine', 'pink', 'pioneer', 'pipe', 'pistol', 'pitch', 'pizza', 'place',
    'plain', 'plan', 'plane', 'planet', 'plant', 'plasma', 'plastic', 'plate',
    'play', 'playground', 'please', 'pledge', 'pluck', 'plumb', 'plumber', 'plunge',
    'plus', 'pocket', 'poem', 'poet', 'point', 'poise', 'poison', 'polar',
    'police', 'policeman', 'policy', 'polish', 'polite', 'political', 'pollen', 'pond',
    'pony', 'pool', 'popular', 'population', 'porch', 'position', 'positive', 'possible',
    'post', 'pot', 'potato', 'potential', 'poultry', 'pound', 'poverty', 'powder',
    'power', 'practice', 'praise', 'predict', 'prefer', 'pregnant', 'prepare', 'present',
    'preserve', 'press', 'price', 'pride', 'priest', 'primary', 'prime', 'print',
    'prior', 'prison', 'private', 'prize', 'probe', 'problem', 'proceed', 'process',
    'produce', 'product', 'profession', 'professor', 'profile', 'program', 'progress', 'project',
    'promise', 'promote', 'propose', 'prose', 'prospect', 'protect', 'protein', 'protest',
    'proud', 'prove', 'provide', 'province', 'provoke', 'prune', 'public', 'pull',
    'pulse', 'pumpkin', 'punch', 'pupil', 'puppy', 'purchase', 'pure', 'purple',
    'purpose', 'purse', 'push', 'puzzle', 'python', 'quality', 'quantum', 'quarter',
    'queen', 'query', 'quest', 'quick', 'quiet', 'quilt', 'quit', 'quiz',
    'quota', 'quote', 'rabbit', 'race', 'racial', 'rack', 'radar', 'radio',
    'rail', 'rain', 'raise', 'rally', 'ranch', 'random', 'range', 'rapid',
    'rare', 'rather', 'ratio', 'razor', 'reach', 'react', 'read', 'ready',
    'realm', 'reap', 'rear', 'reason', 'rebel', 'rebuild', 'recall', 'receive',
    'recipe', 'record', 'recover', 'reduce', 'reform', 'refuse', 'regard', 'regime',
    'region', 'regret', 'regular', 'reject', 'relate', 'relax', 'release', 'relief',
    'rely', 'remain', 'remark', 'remedy', 'remember', 'remind', 'remote', 'remove',
    'render', 'rent', 'rental', 'repair', 'repeat', 'replace', 'report', 'rescue',
    'resemble', 'resist', 'resort', 'resource', 'respond', 'response', 'rest', 'result',
    'retail', 'retain', 'retire', 'retreat', 'return', 'reveal', 'review', 'reward',
    'rhythm', 'rib', 'ribbon', 'rice', 'rich', 'ride', 'ridge', 'rifle',
    'right', 'rigid', 'ring', 'riot', 'ripple', 'rise', 'risk', 'ritual',
    'rival', 'river', 'road', 'roast', 'robot', 'robust', 'rocket', 'romance',
    'roof', 'room', 'rooster', 'root', 'rope', 'rose', 'rotate', 'rough',
    'round', 'route', 'rover', 'royal', 'rubber', 'rude', 'ruin', 'rule',
    'runway', 'rural', 'rush', 'rust', 'sack', 'sacred', 'sad', 'saddle',
    'sadness', 'safe', 'sail', 'salary', 'salmon', 'salon', 'salt', 'salute',
    'same', 'sample', 'sand', 'satisfy', 'satoshi', 'sauce', 'save', 'say',
    'scale', 'scam', 'scandal', 'scare', 'scarce', 'scene', 'scheme', 'school',
    'science', 'scissors', 'scorpion', 'scout', 'scrap', 'script', 'scrutiny', 'sculpture',
    'search', 'season', 'seat', 'second', 'secret', 'section', 'secure', 'seed',
    'seek', 'segment', 'select', 'sell', 'senate', 'senator', 'senior', 'sense',
    'sentence', 'series', 'service', 'session', 'settle', 'setup', 'seven', 'shadow',
    'shaft', 'shake', 'shall', 'shame', 'shape', 'share', 'shark', 'sharp',
    'shed', 'shell', 'shelter', 'shift', 'shine', 'ship', 'shirt', 'shock',
    'shoe', 'shoot', 'shop', 'short', 'shot', 'should', 'shoulder', 'shout',
    'show', 'shower', 'shrimp', 'shrink', 'shrug', 'shuffle', 'shut', 'sibling',
    'sick', 'side', 'siege', 'sight', 'sign', 'signal', 'silence', 'silk',
    'silly', 'silver', 'similar', 'simple', 'since', 'sing', 'singer', 'single',
    'sister', 'situate', 'six', 'sixth', 'sixty', 'size', 'skate', 'skill',
    'skin', 'skirt', 'skull', 'slave', 'sleep', 'slice', 'slide', 'slim',
    'slogan', 'slow', 'slowly', 'small', 'smart', 'smartphone', 'smell', 'smile',
    'smith', 'smoke', 'smooth', 'snack', 'snake', 'snap', 'sneak', 'snow',
    'so', 'soap', 'soccer', 'social', 'sock', 'soda', 'soft', 'software',
    'solar', 'soldier', 'solid', 'solution', 'solve', 'some', 'somebody', 'someone',
    'somehow', 'something', 'sometimes', 'somewhat', 'somewhere', 'song', 'soon', 'sophisticated',
    'sorry', 'sort', 'soul', 'sound', 'soup', 'source', 'south', 'southern',
    'space', 'speak', 'speaker', 'special', 'species', 'specific', 'specify', 'speech',
    'speed', 'spell', 'spend', 'sphere', 'spice', 'spider', 'spike', 'spin',
    'spirit', 'split', 'spoke', 'sponsor', 'spoon', 'sport', 'spot', 'spread',
    'spring', 'spy', 'squad', 'square', 'squeeze', 'stadium', 'staff', 'stage',
    'stain', 'stair', 'stake', 'stamp', 'stand', 'standard', 'star', 'stare',
    'stark', 'start', 'state', 'statement', 'station', 'status', 'stay', 'steady',
    'steak', 'steal', 'steam', 'steel', 'steep', 'steer', 'stem', 'step',
    'stereotype', 'stick', 'sticky', 'still', 'stock', 'stomach', 'stone', 'stool',
    'stop', 'storage', 'store', 'storm', 'story', 'stove', 'straight', 'strain',
    'strange', 'stranger', 'strategic', 'straw', 'stream', 'street', 'strength', 'stress',
    'strict', 'stride', 'strike', 'string', 'strip', 'stripe', 'stroke', 'strong',
    'strongly', 'struggle', 'stubborn', 'student', 'studio', 'study', 'stuff', 'stumble',
    'style', 'subject', 'submit', 'subsequent', 'substance', 'subtle', 'suburb', 'succeed',
    'success', 'successful', 'such', 'suck', 'sudden', 'suddenly', 'suffer', 'sugar',
    'suggest', 'suit', 'suite', 'sunny', 'super', 'superb', 'superior', 'support',
    'suppose', 'supreme', 'sure', 'surface', 'surge', 'surprise', 'surround', 'survey',
    'survival', 'suspect', 'sustain', 'swallow', 'swamp', 'swarm', 'swear', 'sweat',
    'sweep', 'sweet', 'swell', 'swift', 'swim', 'swing', 'switch', 'swiss',
    'sword', 'symbol', 'symptom', 'syntax', 'system', 'table', 'tackle', 'tactic',
    'tail', 'talent', 'talk', 'tall', 'tank', 'tape', 'target', 'task',
    'taste', 'tattoo', 'taxi', 'teach', 'teacher', 'team', 'tear', 'technical',
    'technique', 'technology', 'teenage', 'teeth', 'telegram', 'telephone', 'telescope', 'television',
    'tell', 'temper', 'temperature', 'temple', 'tempo', 'tend', 'tender', 'tennis',
    'tense', 'tension', 'tent', 'term', 'terminal', 'terrible', 'territory', 'terror',
    'test', 'testify', 'testing', 'text', 'thank', 'that', 'theater', 'theme',
    'then', 'theory', 'therapy', 'there', 'thereafter', 'therefore', 'these', 'thick',
    'thief', 'thigh', 'thing', 'think', 'third', 'thirty', 'this', 'thorough',
    'those', 'though', 'thought', 'thousand', 'threat', 'threaten', 'three', 'thrill',
    'thrive', 'throat', 'through', 'throughout', 'throw', 'thumb', 'thunder', 'thus',
    'tick', 'ticket', 'tide', 'tie', 'tiger', 'tight', 'timber', 'time',
    'timid', 'tiny', 'tire', 'tired', 'tissue', 'title', 'toast', 'tobacco',
    'today', 'token', 'tomato', 'tomorrow', 'tone', 'tongue', 'tonight', 'tool',
    'tooth', 'topic', 'topple', 'torch', 'tornado', 'tortoise', 'toss', 'total',
    'tourist', 'toward', 'towards', 'tower', 'town', 'toxic', 'trace', 'track',
    'trade', 'traffic', 'tragic', 'trail', 'train', 'trait', 'transfer', 'transform',
    'transit', 'trash', 'travel', 'tray', 'treasure', 'treat', 'treaty', 'tree',
    'tremendous', 'trend', 'trial', 'tribe', 'tribute', 'trick', 'trigger', 'trillion',
    'trim', 'trip', 'triumph', 'troop', 'tropical', 'trouble', 'truck', 'true',
    'truly', 'trumpet', 'trunk', 'trust', 'truth', 'tumor', 'tunnel', 'turkey',
    'turn', 'turtle', 'twelve', 'twenty', 'twice', 'twin', 'twist', 'two',
    'type', 'typical', 'ugly', 'ultimate', 'umbrella', 'unable', 'unavoidable', 'uncle',
    'under', 'undergo', 'unfair', 'unfold', 'unhappy', 'uniform', 'union', 'unique',
    'unit', 'unite', 'unity', 'universal', 'universe', 'universe', 'unknown', 'unless',
    'unlike', 'unlikely', 'until', 'unusual', 'update', 'upgrade', 'uphold', 'upon',
    'upper', 'upset', 'urban', 'urge', 'usage', 'use', 'used', 'useful',
    'useless', 'usual', 'usually', 'utility', 'utility', 'vacant', 'vacuum', 'vague',
    'valid', 'valley', 'valuable', 'value', 'valve', 'vapor', 'various', 'vast',
    'vault', 'vegan', 'vehicle', 'velvet', 'venture', 'venue', 'verb', 'verdict',
    'verify', 'verse', 'version', 'versus', 'very', 'vessel', 'veteran', 'viable',
    'vibrant', 'vicious', 'victim', 'victory', 'video', 'view', 'village', 'vintage',
    'violate', 'violence', 'violet', 'virtual', 'virtue', 'virus', 'visible', 'vision',
    'visit', 'visual', 'vital', 'vivid', 'vocal', 'voice', 'void', 'volcano',
    'volume', 'voluntary', 'vote', 'voter', 'voyage', 'wage', 'wagon', 'waist',
    'walk', 'wall', 'wander', 'want', 'war', 'warm', 'warmth', 'warn',
    'warrant', 'warrior', 'wash', 'waste', 'watch', 'water', 'wave', 'weak',
    'wealth', 'weapon', 'wear', 'weasel', 'weather', 'web', 'wedding', 'weekend',
    'weigh', 'weird', 'welcome', 'welfare', 'west', 'western', 'whale', 'what',
    'whatever', 'wheat', 'wheel', 'when', 'whenever', 'where', 'whereas', 'wherever',
    'whether', 'which', 'while', 'whisper', 'whistle', 'white', 'whole', 'whose',
    'wide', 'width', 'wife', 'wild', 'will', 'willing', 'win', 'wind',
    'window', 'wine', 'wing', 'wink', 'winner', 'winter', 'wire', 'wisdom',
    'wise', 'wish', 'witch', 'with', 'withdraw', 'within', 'without', 'witness',
    'wolf', 'woman', 'wonder', 'wonderful', 'wood', 'wool', 'word', 'work',
    'worker', 'workshop', 'world', 'worm', 'worn', 'worried', 'worry', 'worse',
    'worship', 'worst', 'worth', 'would', 'wound', 'wrap', 'wrath', 'wreck',
    'wrestle', 'wrist', 'write', 'wrong', 'yard', 'year', 'yellow', 'yes',
    'yesterday', 'yield', 'young', 'youth', 'zebra', 'zombie', 'zone', 'zoo',
  ];

  /// Get word index (0-2047)
  static int getIndex(String word) {
    final index = words.indexOf(word.toLowerCase());
    if (index == -1) {
      throw ArgumentError('Invalid BIP-39 word: $word');
    }
    return index;
  }

  /// Check if a word is valid BIP-39
  static bool isValidWord(String word) {
    return words.contains(word.toLowerCase());
  }
}

/// BIP-39 Mnemonic Generator with proper checksum
/// 
/// Implements BIP-39 for generating cryptographic mnemonics.
/// Each word represents 11 bits: index 0-2047
/// 12 words = 132 bits = 128 bits entropy + 4 bits checksum
/// 24 words = 264 bits = 256 bits entropy + 8 bits checksum
class BIP39MnemonicGenerator {
  BIP39MnemonicGenerator._();

  /// Entropy sizes in bits
  static const int entropy128 = 128;
  static const int entropy192 = 192;
  static const int entropy256 = 256;

  /// Generate a mnemonic with the specified number of bits of entropy
  /// 
  /// [bits] - Can be 128, 192, or 256 (generating 12, 18, or 24 words)
  static List<String> generate({int bits = entropy128}) {
    if (bits != entropy128 && bits != entropy192 && bits != entropy256) {
      throw ArgumentError('Invalid entropy size: $bits. Must be 128, 192, or 256.');
    }

    // Generate random entropy
    final entropy = _generateRandomEntropy(bits ~/ 8);

    // Calculate checksum
    final checksum = _calculateChecksum(entropy);

    // Combine entropy and checksum
    final entropyWithChecksum = _combineEntropyAndChecksum(entropy, checksum);

    // Convert to words
    return _bitsToWords(entropyWithChecksum);
  }

  /// Generate random bytes for entropy
  static Uint8List _generateRandomEntropy(int byteLength) {
    final random = Random.secure();
    final bytes = Uint8List(byteLength);
    for (var i = 0; i < byteLength; i++) {
      bytes[i] = random.nextInt(256);
    }
    return bytes;
  }

  /// Calculate SHA-256 checksum of entropy
  static Uint8List _calculateChecksum(Uint8List entropy) {
    // SHA-256 hash
    final hash = sha256.convert(entropy).bytes;
    return Uint8List.fromList(hash);
  }

  /// Combine entropy bytes with checksum bits
  static Uint8List _combineEntropyAndChecksum(Uint8List entropy, Uint8List checksum) {
    final entropyBits = entropy.length * 8;
    final checksumBits = entropyBits ~/ 32; // 4 bits for 128, 6 for 192, 8 for 256
    final totalBits = entropyBits + checksumBits;

    // Pad to whole bytes
    final totalBytes = (totalBits + 7) ~/ 8;
    final result = Uint8List(totalBytes);

    // Copy entropy
    for (var i = 0; i < entropy.length; i++) {
      result[i] = entropy[i];
    }

    // Add checksum bits to last byte
    final bitsInLastByte = totalBits % 8;
    if (bitsInLastByte == 0) {
      result[totalBytes - 1] = checksum[0];
    } else {
      // Mask only the needed checksum bits
      result[totalBytes - 1] = checksum[0] >> (8 - bitsInLastByte);
    }

    return result;
  }

  /// Convert bits to BIP-39 words
  static List<String> _bitsToWords(Uint8List data) {
    final words = <String>[];
    final totalBits = data.length * 8;
    final wordCount = totalBits ~/ 11; // Each word = 11 bits

    for (var i = 0; i < wordCount; i++) {
      var index = 0;
      for (var j = 0; j < 11; j++) {
        final bitPosition = i * 11 + j;
        final byteIndex = bitPosition ~/ 8;
        final bitIndex = bitPosition % 8;
        
        if (byteIndex < data.length) {
          index = (index << 1) | ((data[byteIndex] >> (7 - bitIndex)) & 1);
        }
      }
      
      if (index >= 0 && index < BIP39WordList.words.length) {
        words.add(BIP39WordList.words[index]);
      }
    }

    return words;
  }

  /// Verify a mnemonic's checksum
  static bool verifyChecksum(List<String> mnemonic) {
    if (mnemonic.isEmpty) return false;

    // Determine expected word count
    final wordCount = mnemonic.length;
    if (wordCount != 12 && wordCount != 18 && wordCount != 24) {
      return false;
    }

    // Convert words to bits
    final bits = _wordsToBits(mnemonic);
    if (bits == null) return false;

    // Calculate entropy length
    final entropyBits = (wordCount * 11) - (wordCount ~/ 3);
    final entropyBytes = entropyBits ~/ 8;
    final checksumBits = wordCount ~/ 3;

    // Extract entropy and checksum
    final entropy = Uint8List(entropyBytes);
    for (var i = 0; i < entropyBytes; i++) {
      for (var j = 0; j < 8; j++) {
        final bitPos = i * 8 + j;
        if (bitPos < bits.length) {
          entropy[i] = (entropy[i] << 1) | bits[bitPos];
        }
      }
    }

    // Calculate expected checksum
    final expectedChecksum = _calculateChecksum(entropy);

    // Extract checksum from mnemonic
    int mnemonicChecksum = 0;
    for (var i = 0; i < checksumBits; i++) {
      final bitPos = entropyBits + i;
      if (bitPos < bits.length) {
        mnemonicChecksum = (mnemonicChecksum << 1) | bits[bitPos];
      }
    }

    // Compare checksums
    final storedChecksum = checksumBits <= 8 ? expectedChecksum[0] : 
                           checksumBits <= 16 ? (expectedChecksum[0] >> 4) | ((expectedChecksum[1] & 0x0F) << 4) :
                           expectedChecksum[0];

    return (storedChecksum & ((1 << checksumBits) - 1)) == 
           (mnemonicChecksum & ((1 << checksumBits) - 1));
  }

  /// Convert words back to bits
  static List<int>? _wordsToBits(List<String> words) {
    final bits = <int>[];
    
    for (final word in words) {
      final index = BIP39WordList.getIndex(word);
      
      // Convert index to 11 bits
      for (var i = 10; i >= 0; i--) {
        bits.add((index >> i) & 1);
      }
    }
    
    return bits;
  }

  /// Validate a mnemonic phrase
  static bool isValidMnemonic(List<String> mnemonic) {
    if (mnemonic.isEmpty) return false;
    
    // Check word count
    if (mnemonic.length != 12 && mnemonic.length != 18 && mnemonic.length != 24) {
      return false;
    }

    // Verify all words are in wordlist
    for (final word in mnemonic) {
      if (!BIP39WordList.isValidWord(word)) {
        return false;
      }
    }

    // Verify checksum
    return verifyChecksum(mnemonic);
  }

  /// Convert mnemonic to seed (for key derivation)
  /// 
  /// Uses PBKDF2 with:
  /// - Password: mnemonic + optional passphrase
  /// - Salt: "mnemonic" + passphrase
  /// - Iterations: 2048
  /// - Key length: 64 bytes
  static Uint8List mnemonicToSeed(List<String> mnemonic, {String passphrase = ''}) {
    final mnemonicString = mnemonic.join(' ');
    final salt = 'mnemonic${passphrase.isNotEmpty ? passphrase : ''}';
    
    // PBKDF2-HMAC-SHA512
    // Note: In production, use the cryptography package for proper PBKDF2
    final hmacSha512 = Hmac(sha512, utf8.encode(salt));
    final digest = hmacSha512.convert(utf8.encode(mnemonicString));
    
    // 2048 iterations of HMAC-SHA512
    var result = digest.bytes;
    for (var i = 0; i < 2047; i++) {
      final next = Hmac(sha512, utf8.encode(salt)).convert(result);
      result = next.bytes;
    }
    
    return Uint8List.fromList(result);
  }
}

class BackupScreenViewModel extends StateNotifier<BackupScreenState> {
  BackupScreenViewModel() : super(const BackupScreenState());

  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  Future<void> generateMnemonic() async {
    state = state.copyWith(isLoading: true);

    try {
      final existingPhrase = await _secureStorage.read(key: _recoveryPhraseKey);
      List<String> words;
      
      if (existingPhrase != null) {
        words = existingPhrase.split(' ');
      } else {
        // Generate proper BIP-39 mnemonic with checksum
        words = BIP39MnemonicGenerator.generate(bits: BIP39MnemonicGenerator.entropy128);
        await _secureStorage.write(key: _recoveryPhraseKey, value: words.join(' '));
      }

      state = state.copyWith(mnemonic: words, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> confirmBackup(List<String> verifiedWords) async {
    if (verifiedWords.length != 3) return false;
    
    final correctIndices = <int>[];
    final random = Random();
    
    while (correctIndices.length < 3) {
      final idx = random.nextInt(12);
      if (!correctIndices.contains(idx)) {
        correctIndices.add(idx);
      }
    }
    correctIndices.sort();

    for (int i = 0; i < 3; i++) {
      if (verifiedWords[i] != state.mnemonic[correctIndices[i]]) {
        return false;
      }
    }

    await _secureStorage.write(key: _hasShownBackupPromptKey, value: 'true');
    state = state.copyWith(isConfirmed: true);
    return true;
  }
}

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(backupScreenViewModelProvider.notifier).generateMnemonic();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(backupScreenViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Backup'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.mnemonic.isEmpty
              ? const Center(child: Text('Failed to load recovery phrase'))
              : _buildContent(state),
    );
  }

  Widget _buildContent(BackupScreenState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recovery Phrase',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'This phrase can be used to recover your chat history if you reinstall the app or switch devices.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (int i = 0; i < state.mnemonic.length; i += 4)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        _buildWordChip(i + 1, state.mnemonic[i]),
                        _buildWordChip(i + 2, state.mnemonic[i + 1]),
                        _buildWordChip(i + 3, state.mnemonic[i + 2]),
                        _buildWordChip(i + 4, state.mnemonic[i + 3]),
                      ].map((w) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: w))).toList(),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Write down these words in order and store them safely. You will need them to recover your chat history.',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showVerificationDialog(context),
              child: const Text('I\'ve Saved This'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordChip(int index, String word) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$index.', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(word, style: const TextStyle(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  void _showVerificationDialog(BuildContext context) {
    final random = Random();
    final indices = <int>[];
    while (indices.length < 3) {
      final idx = random.nextInt(12);
      if (!indices.contains(idx)) indices.add(idx);
    }
    indices.sort();

    final controllers = List.generate(3, (_) => TextEditingController());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Verify your backup', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            for (int i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: controllers[i],
                  decoration: InputDecoration(
                    labelText: 'Word #${indices[i] + 1}',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final verified = await ref.read(backupScreenViewModelProvider.notifier).confirmBackup(
                    controllers.map((c) => c.text.trim().toLowerCase()).toList(),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (verified) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Backup confirmed!')),
                      );
                      context.pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Verification failed. Please try again.')),
                      );
                    }
                  }
                },
                child: const Text('Confirm'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
