package com.example.demo.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.entity.DishReview;
import com.example.demo.repository.DishReviewRepository;

@RestController
@RequestMapping("/dish-reviews")
public class DishReviewController {
    @Autowired
    private DishReviewRepository dishReviewRepository;

    @GetMapping("/canteen/{canteenId}")
    public List<DishReview> getReviewsByCanteen(@PathVariable String canteenId) {
        return dishReviewRepository.findByCanteenIdOrderByCreatedAtDesc(canteenId);
    }

    @GetMapping("/canteen/{canteenId}/dish/{dishName}")
    public List<DishReview> getReviewsByDish(@PathVariable String canteenId, @PathVariable String dishName) {
        return dishReviewRepository.findByCanteenIdAndDishNameOrderByCreatedAtDesc(canteenId, dishName);
    }

    @GetMapping("/user/{username}")
    public List<DishReview> getReviewsByUser(@PathVariable String username) {
        return dishReviewRepository.findByUsernameOrderByCreatedAtDesc(username);
    }

    @GetMapping("/average-rating")
    public Double getAverageRating(@RequestParam String canteenId, @RequestParam String dishName) {
        return dishReviewRepository.findAverageRatingByCanteenIdAndDishName(canteenId, dishName);
    }

    @GetMapping("/distinct-dishes/{canteenId}")
    public List<String> getDistinctDishes(@PathVariable String canteenId) {
        return dishReviewRepository.findDistinctDishNamesByCanteenId(canteenId);
    }

    @PostMapping
    public DishReview createDishReview(@RequestBody DishReview review) {
        return dishReviewRepository.save(review);
    }

    @PutMapping("/{id}")
    public DishReview updateDishReview(@PathVariable Long id, @RequestBody DishReview review) {
        review.setId(id);
        return dishReviewRepository.save(review);
    }

    @DeleteMapping("/{id}")
    public void deleteDishReview(@PathVariable Long id) {
        dishReviewRepository.deleteById(id);
    }
} 