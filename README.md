# Sync Todo

Flutter製のシンプルなAndroid向けタスク管理（ToDo）アプリです。

## 主な機能
- タスクの追加・編集・削除
- タスクの完了/未完了状態の切り替え
- 完了済みタスクの表示/非表示切り替え
- ローカルストレージ（Hive）によるデータ永続化

## 画面構成
- ホーム画面：タスク一覧表示、タスク追加ボタン、完了タスク表示トグル
- タスク追加画面：新規タスクの入力・保存
- タスク編集画面：既存タスクの編集・削除

## ディレクトリ構成（主要部分）
- lib/
  - main.dart ... アプリのエントリーポイント
  - models/task.dart ... タスクデータのモデル（Hive対応）
  - repositories/task_repository.dart ... タスクのデータ操作（取得・保存・削除等）
  - screens/home_screen.dart ... タスク一覧画面
  - screens/add_task_screen.dart ... タスク追加画面
  - screens/edit_task_screen.dart ... タスク編集画面
  - widgets/task_item.dart ... タスク表示用ウィジェット
  - theme.dart ... アプリのテーマ設定

## 依存パッケージ
- flutter
- hive, hive_flutter
- path_provider
- uuid

## 使い方
1. `flutter pub get` で依存パッケージを取得
2. `flutter run` でアプリを起動
