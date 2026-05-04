import 'package:book_user_app/core/errors/failures.dart';
import 'package:book_user_app/core/services/socket_service.dart';
import 'package:book_user_app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:book_user_app/features/chat/data/models/chat_message.dart';
import 'package:book_user_app/features/chat/data/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockChatRemoteDataSource extends Mock implements ChatRemoteDataSource {}

class _MockSocketService extends Mock implements SocketService {}

void main() {
  late _MockChatRemoteDataSource remote;
  late _MockSocketService socket;
  late ChatRepository repo;

  final serverMessage = ChatMessage(
    id: 'm1',
    conversation: 'c1',
    sender: const MessageSender(id: 'u1', name: 'You'),
    text: 'hi',
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
  );

  setUp(() {
    remote = _MockChatRemoteDataSource();
    socket = _MockSocketService();
    repo = ChatRepository(remoteDataSource: remote, socketService: socket);
  });

  group('sendMessage', () {
    test('uses socket when connected and returns Right(null)', () async {
      when(() => socket.isConnected).thenReturn(true);
      when(
        () => socket.sendMessage(
          conversationId: any(named: 'conversationId'),
          text: any(named: 'text'),
          image: any(named: 'image'),
          messageType: any(named: 'messageType'),
          metadata: any(named: 'metadata'),
          location: any(named: 'location'),
        ),
      ).thenReturn(null);

      final result = await repo.sendMessage(
        conversationId: 'c1',
        text: 'hello',
      );

      expect(result, const Right<Failure, ChatMessage?>(null));
      verify(
        () => socket.sendMessage(
          conversationId: 'c1',
          text: 'hello',
          image: null,
          messageType: null,
          metadata: null,
          location: null,
        ),
      ).called(1);
      verifyNever(() => remote.sendMessage(any(), text: any(named: 'text')));
    });

    test('HTTP fallback when socket down returns server message', () async {
      when(() => socket.isConnected).thenReturn(false);
      when(
        () => remote.sendMessage('c1', text: 'hello'),
      ).thenAnswer((_) async => serverMessage);

      final result = await repo.sendMessage(
        conversationId: 'c1',
        text: 'hello',
      );

      expect(result, Right<Failure, ChatMessage?>(serverMessage));
      verifyNever(
        () => socket.sendMessage(
          conversationId: any(named: 'conversationId'),
          text: any(named: 'text'),
          image: any(named: 'image'),
          messageType: any(named: 'messageType'),
          metadata: any(named: 'metadata'),
          location: any(named: 'location'),
        ),
      );
    });

    test('offer when socket down returns failure', () async {
      when(() => socket.isConnected).thenReturn(false);

      final result = await repo.sendMessage(
        conversationId: 'c1',
        text: 'x',
        messageType: 'offer',
        metadata: const {'offerId': 'o1'},
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f.message, contains('Reconnect')),
        (_) => fail('expected Left'),
      );
      verifyNever(() => remote.sendMessage(any(), text: any(named: 'text')));
    });
  });

  group('sendLocationMessage', () {
    test('fails when socket disconnected', () async {
      when(() => socket.isConnected).thenReturn(false);

      final result = await repo.sendLocationMessage(
        conversationId: 'c1',
        latitude: 1,
        longitude: 2,
      );

      expect(result.isLeft(), isTrue);
      verifyNever(
        () => socket.sendMessage(
          conversationId: any(named: 'conversationId'),
          text: any(named: 'text'),
          image: any(named: 'image'),
          messageType: any(named: 'messageType'),
          metadata: any(named: 'metadata'),
          location: any(named: 'location'),
        ),
      );
    });
  });
}
