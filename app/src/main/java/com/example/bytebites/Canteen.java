package com.example.bytebites;

public class Canteen {
    String name;
    String description;
    float rating;

    public Canteen(String name, String description, float rating) {
        this.name = name;
        this.description = description;
        this.rating = rating;
    }

    // Getters
    public String getName() { return name; }
    public String getDescription() { return description; }
    public float getRating() { return rating; }
}
