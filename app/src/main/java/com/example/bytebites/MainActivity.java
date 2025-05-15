
package com.example.bytebites;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.net.Uri;
import android.widget.Toast;
import android.content.SharedPreferences;

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
                String enteredUser = usernameEditText.getText().toString();
                String enteredPass = passwordEditText.getText().toString();

                // 从 SharedPreferences 读取注册时保存的用户名/密码
                SharedPreferences prefs = getSharedPreferences("UserPrefs", MODE_PRIVATE);
                String savedUser = prefs.getString("username", "");
                String savedPass = prefs.getString("password", "");

                // 校验
                if (enteredUser.equals(savedUser) && enteredPass.equals(savedPass)) {
                    // 登录成功，跳转到主页
                    Intent toHome = new Intent(MainActivity.this, HomeActivity.class);
                    startActivity(toHome);
                    finish(); // 登录后不返回登录页
                } else {
                    // 登录失败，弹出错误提示
                    Toast.makeText(MainActivity.this,
                            "Username or password incorrect!", Toast.LENGTH_SHORT).show();
                }
            }
        });

        signupButton = findViewById(R.id.buttonSignup);
        signupButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // 跳转到 RegisterActivity
                Intent intent = new Intent(MainActivity.this, RegisterActivity.class);
                startActivity(intent);
            }
        });

    }
}
