package com.example.ai.ui;

import com.example.ai.service.OllamaService;
import javafx.application.Application;
import javafx.geometry.Insets;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

public class ChatUI extends Application {

    private OllamaService ollamaService = new OllamaService();

    @Override
    public void start(Stage stage) {
        TextArea chatArea = new TextArea();
        chatArea.setEditable(false);
        chatArea.setWrapText(true);

        TextField inputField = new TextField();
        inputField.setPromptText("Напиши сообщение...");

        Button sendButton = new Button("Отправить");

        sendButton.setOnAction(e -> {
            String userText = inputField.getText();
            if (userText.isEmpty()) return;

            chatArea.appendText("Ты: " + userText + "\n");

            String response = ollamaService.ask(userText);

            chatArea.appendText("ИИ: " + response + "\n\n");

            inputField.clear();
        });

        VBox layout = new VBox(10, chatArea, inputField, sendButton);
        layout.setPadding(new Insets(10));

        Scene scene = new Scene(layout, 500, 600);

        stage.setTitle("AI Chat (Ollama)");
        stage.setScene(scene);
        stage.show();
    }

    public static void main(String[] args) {
        launch();
    }
}