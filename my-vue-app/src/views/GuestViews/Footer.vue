<template>
  <footer class="footer">
    <div class="footer-content">
      <div class="contact-info">
        <p><strong>HealthRight International</strong></p>
        <p>708 Broadway, Suite 601, New York, NY 10003</p>
        <p><strong>Phone:</strong> 212-226-9890</p>
        <p><strong>Email:</strong> <a href="mailto:info@healthright.org">info@healthright.org</a></p>
        <button class="donate">Donate</button>
      </div>
      <div class="subscribe">
        <h3>Stay Connected!</h3>
        <input type="text" placeholder="First Name" />
        <input type="text" placeholder="Last Name" />
        <input type="email" placeholder="Email Address" />
        <select>
          <option>Ukraine War Relief</option>
          <option>Reproductive and Maternal Health</option>
          <option>Adolescent Health</option>
          <option>Mental Health</option>
        </select>
        <button>Subscribe</button>
      </div>
    </div>
  </footer>
</template>

<script>
export default {
  name: 'AppFooter',
};
</script>

<style scoped>
/* Reset CSS cơ bản */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

.footer {
  width: 100vw;
  position: relative;
  left: 50%;
  right: 50%;
  margin-left: -50vw;
  margin-right: -50vw;
  background: white;
  border-top: 2px solid #f4f4f4;
  box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1);
}

.footer-content {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 40px 20px;
}

.contact-info {
  flex: 1;
  max-width: 400px;
}

.contact-info p {
  margin: 8px 0;
  color: #333;
  line-height: 1.5;
}

.contact-info a {
  color: #ffd700;
  text-decoration: none;
  transition: color 0.3s ease;
}

.contact-info a:hover {
  color: #ffed4a;
}

.subscribe {
  flex: 1;
  max-width: 400px;
}

.subscribe h3 {
  margin-bottom: 20px;
  color: #333;
}

.subscribe input,
.subscribe select {
  display: block;
  width: 100%;
  margin: 10px 0;
  padding: 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.subscribe button {
  width: 100%;
  padding: 12px;
  background: navy;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 16px;
  transition: background-color 0.3s ease;
}

.subscribe button:hover {
  background: #000080;
}

.donate {
  margin-top: 15px;
  padding: 12px 25px;
  background: #ffd700;
  color: black;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: bold;
  transition: background-color 0.3s ease;
}

.donate:hover {
  background: #ffed4a;
}

/* Responsive Design */
@media (max-width: 768px) {
  .footer-content {
    flex-direction: column;
    padding: 20px;
  }
  
  .contact-info,
  .subscribe {
    max-width: 100%;
    margin-bottom: 30px;
  }
}
</style>