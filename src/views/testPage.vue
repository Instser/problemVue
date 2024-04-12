<script setup>
import axios from "axios";
import {ref} from "vue";

axios.get('/api/quesFolder/getFolder').then(res => {
  console.log(res.data.data)
  text.value = res.data.data
})
const text = ref('默认')

</script>

<template>
<p>{{ text }}</p>
</template>

<style scoped>

</style>