package com.htetaung.lms.ejbs.facades;

import com.htetaung.lms.models.Notification;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;

import java.util.List;

@Stateless
public class NotificationFacade extends AbstractFacade<Notification> {

    @PersistenceContext
    private EntityManager em;

    public NotificationFacade() {
        super(Notification.class);
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public List<Notification> findByUserId(Long userId) {
        TypedQuery<Notification> query = em.createQuery(
                "SELECT n FROM Notification n WHERE n.user.userId = :userId ORDER BY n.createdAt DESC", 
                Notification.class);
        query.setParameter("userId", userId);
        return query.getResultList();
    }

    public List<Notification> findUnreadByUserId(Long userId) {
        TypedQuery<Notification> query = em.createQuery(
                "SELECT n FROM Notification n WHERE n.user.userId = :userId AND n.isRead = false ORDER BY n.createdAt DESC", 
                Notification.class);
        query.setParameter("userId", userId);
        return query.getResultList();
    }

    public Long countUnreadByUserId(Long userId) {
        TypedQuery<Long> query = em.createQuery(
                "SELECT COUNT(n) FROM Notification n WHERE n.user.userId = :userId AND n.isRead = false", 
                Long.class);
        query.setParameter("userId", userId);
        return query.getSingleResult();
    }
}

