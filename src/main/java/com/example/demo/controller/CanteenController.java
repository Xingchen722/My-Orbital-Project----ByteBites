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
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.entity.Canteen;
import com.example.demo.repository.CanteenRepository;

@RestController
@RequestMapping("/canteens")
public class CanteenController {

    @Autowired
    private CanteenRepository canteenRepository;

    @GetMapping
    public List<Canteen> getAllCanteens() {
        return canteenRepository.findAll();
    }

    @GetMapping("/{id}")
    public Canteen getCanteenById(@PathVariable String id) {
        return canteenRepository.findById(id).orElse(null);
    }

    @PostMapping
    public Canteen createCanteen(@RequestBody Canteen canteen) {
        return canteenRepository.save(canteen);
    }

    @PutMapping("/{id}")
    public Canteen updateCanteen(@PathVariable String id, @RequestBody Canteen canteen) {
        canteen.setId(id);
        return canteenRepository.save(canteen);
    }

    @DeleteMapping("/{id}")
    public void deleteCanteen(@PathVariable String id) {
        canteenRepository.deleteById(id);
    }
} 