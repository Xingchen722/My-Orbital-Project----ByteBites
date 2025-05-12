
package com.example.bytebites;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.net.Uri;
import android.widget.Toast;



import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {
    EditText usernameEditText, passwordEditText;
    Button loginButton;
    Button signupButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        usernameEditText = findViewById(R.id.editTextUsername);
        passwordEditText = findViewById(R.id.editTextPassword);
        loginButton = findViewById(R.id.buttonLogin);

        loginButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                // 这里你可以做用户名密码验证
                // 登录成功后跳转到 HomeActivity
                Intent intent = new Intent(MainActivity.this, HomeActivity.class);
                startActivity(intent);
                finish(); // 不让用户回退到登录页
            }
        });

        Button signupButton = findViewById(R.id.buttonSignup);
        signupButton.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//            Intent emailIntent = new Intent(Intent.ACTION_SENDTO);
//            emailIntent.setData(Uri.parse("mailto:someone@example.com")); // 收件人邮箱（可以替换）
//            emailIntent.putExtra(Intent.EXTRA_SUBJECT,"Sign Up Request"); // 邮件主题
//            emailIntent.putExtra(Intent.EXTRA_TEXT,"Hi, I would like to sign up for ByteBites!"); // 邮件正文
//
//            // 检查是否有邮件应用可以处理这个 Intent
//            if(emailIntent.resolveActivity(getPackageManager())!=null) {
//                    startActivity(emailIntent); // 启动邮件应用
//                } else {
//                    Toast.makeText(MainActivity.this, "No email app found", Toast.LENGTH_SHORT).show();
//                }
//            }
            @Override
            public void onClick(View v) {
                // 跳转到 RegisterActivity
                Intent intent = new Intent(MainActivity.this, RegisterActivity.class);
                startActivity(intent);
            }
    });

    }
}
