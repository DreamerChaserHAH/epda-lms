package com.htetaung.lms.service;

import com.htetaung.lms.entity.User;
import com.htetaung.lms.exception.AuthenticationException;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Root;

@Stateless
public class AuthenticationService {

    @PersistenceContext
    private EntityManager em;

    public User findByUsername(String username){
        CriteriaBuilder criteriaBuilder = em.getCriteriaBuilder();
        CriteriaQuery<User> criteriaQuery = criteriaBuilder.createQuery(User.class);
        Root<User> root = criteriaQuery.from(User.class);
        criteriaQuery.select(root).where(criteriaBuilder.equal(root.get("username"), username));
        return em.createQuery(criteriaQuery).getSingleResult();
    }

    public User findByUsernameAndRole(String username, User.Role role){
        CriteriaBuilder criteriaBuilder = em.getCriteriaBuilder();
        CriteriaQuery<User> criteriaQuery = criteriaBuilder.createQuery(User.class);
        Root<User> root = criteriaQuery.from(User.class);
        criteriaQuery.select(root).where(
            criteriaBuilder.and(
                criteriaBuilder.equal(root.get("username"), username),
                criteriaBuilder.equal(root.get("role"), role)
            )
        );
        return em.createQuery(criteriaQuery).getSingleResult();
    }

    public User login(String username, String password, User.Role role) throws AuthenticationException {
        User user;
        
        // 1. Check if username exists
        try {
            user = findByUsername(username);
        } catch (jakarta.persistence.NoResultException e) {
            throw new AuthenticationException("Username does not exist");
        }
        
        // 2. Check if password matches
        if (!user.getPassword().equals(password)) {
            throw new AuthenticationException("Password is incorrect");
        }
        
        // 3. Check if username with this role exists
        if (!user.getRole().equals(role)) {
            throw new AuthenticationException("Username with this role does not exist");
        }
        
        return user;
    }
}
